const Order = require('../models/Order');
const Invoice = require('../models/Invoice');
const Product = require('../models/Product');
const Customer = require('../models/Customer');
const { generateInvoiceNumber } = require('../services/invoiceNumberService');
const { deductStock, restoreStock } = require('../services/stockService');

const createOrder = async (req, res) => {
  const { items, paymentMethod, customerName, customerPhone, discountAmount } = req.body;
  const shopId = req.user.shopId;
  const staffId = req.user._id;

  if (!items || items.length === 0) {
    return res.status(400).json({ message: 'Order must contain items' });
  }

  try {
    let subtotal = 0;
    const orderItems = [];

    // 1 & 2: Validate products and calculate server-side totals
    for (let item of items) {
      const product = await Product.findOne({ _id: item.productId, shopId, isActive: true });
      if (!product) {
        return res.status(400).json({ message: `Product ${item.productName || item.productId} not found or inactive` });
      }

      if (product.stock_count < item.quantity) {
        return res.status(400).json({ message: `${product.name}: only ${product.stock_count} ${product.unit} available` });
      }

      const lineTotal = product.sellingPrice * item.quantity;
      subtotal += lineTotal;

      orderItems.push({
        productId: product._id,
        productName: product.name,
        productSku: product.sku,
        unitPrice: product.sellingPrice,
        quantity: item.quantity,
        unit: product.unit,
        lineTotal,
      });
    }

    const taxAmount = subtotal * 0.05; // 5% VAT
    const finalDiscount = discountAmount || 0;
    const totalAmount = subtotal + taxAmount - finalDiscount;

    // 4: Generate unique invoice number
    const invoiceNumber = await generateInvoiceNumber();

    // Handle Customer Linking
    let linkedCustomerId = null;
    if (customerPhone && customerPhone.trim().length > 0) {
      let customer = await Customer.findOne({ shopId, phoneNumber: customerPhone });
      if (!customer) {
        customer = await Customer.create({
          shopId,
          phoneNumber: customerPhone,
          name: customerName || 'Unknown',
          totalSpent: totalAmount,
          visitCount: 1,
        });
      } else {
        customer.totalSpent += totalAmount;
        customer.visitCount += 1;
        // Optionally update name if they changed it
        if (customerName && customerName !== 'Walk-in Customer') {
          customer.name = customerName;
        }
        await customer.save();
      }
      linkedCustomerId = customer._id;
    }

    // 5: Save the Order document
    const order = await Order.create({
      shopId,
      invoiceNumber,
      staffId,
      customerId: linkedCustomerId,
      customerPhone: customerPhone || null,
      customerName: customerName || 'Walk-in Customer',
      paymentMethod,
      items: orderItems,
      subtotal,
      taxAmount,
      discountAmount: finalDiscount,
      totalAmount,
    });

    // 6: Deduct stock for each item
    for (let item of orderItems) {
      await deductStock(item.productId, item.quantity, shopId, staffId, order._id);
    }

    // 7: Save linked Invoice document
    const invoice = await Invoice.create({
      orderId: order._id,
      shopId,
      invoiceNumber,
    });

    res.status(201).json({ order, invoice });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getAllOrders = async (req, res) => {
  const shopId = req.user.shopId;
  const { startDate, endDate, status, paymentMethod, search, page = 1, limit = 20 } = req.query;

  const query = { shopId };

  if (startDate && endDate) {
    query.transactionDate = { $gte: new Date(startDate), $lte: new Date(endDate) };
  }
  if (status) query.status = status;
  if (paymentMethod) query.paymentMethod = paymentMethod;
  if (search) query.invoiceNumber = { $regex: search, $options: 'i' };

  try {
    const skip = (page - 1) * limit;
    const orders = await Order.find(query)
      .populate('staffId', 'name')
      .sort({ transactionDate: -1 })
      .skip(Number(skip))
      .limit(Number(limit));

    const total = await Order.countDocuments(query);

    res.json({
      orders,
      page: Number(page),
      totalPages: Math.ceil(total / limit),
      totalOrders: total,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getMyOrders = async (req, res) => {
  const shopId = req.user.shopId;
  const staffId = req.user._id;
  const { startDate, endDate, status, paymentMethod, search, page = 1, limit = 20 } = req.query;

  const query = { shopId, staffId };

  if (startDate && endDate) {
    query.transactionDate = { $gte: new Date(startDate), $lte: new Date(endDate) };
  }
  if (status) query.status = status;
  if (paymentMethod) query.paymentMethod = paymentMethod;
  if (search) query.invoiceNumber = { $regex: search, $options: 'i' };

  try {
    const skip = (page - 1) * limit;
    const orders = await Order.find(query)
      .populate('staffId', 'name')
      .sort({ transactionDate: -1 })
      .skip(Number(skip))
      .limit(Number(limit));

    const total = await Order.countDocuments(query);

    res.json({
      orders,
      page: Number(page),
      totalPages: Math.ceil(total / limit),
      totalOrders: total,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getOrderById = async (req, res) => {
  const { id } = req.params;
  const shopId = req.user.shopId;

  try {
    const order = await Order.findOne({ _id: id, shopId }).populate('staffId', 'name');
    if (!order) return res.status(404).json({ message: 'Order not found' });
    
    res.json(order);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const voidOrder = async (req, res) => {
  const { id } = req.params;
  const shopId = req.user.shopId;
  const { voidReason } = req.body;

  try {
    const order = await Order.findOne({ _id: id, shopId });
    if (!order) return res.status(404).json({ message: 'Order not found' });

    if (order.status === 'voided') {
      return res.status(400).json({ message: 'Order is already voided' });
    }

    // Restore stock
    for (let item of order.items) {
      await restoreStock(item.productId, item.quantity, shopId, req.user._id, order._id);
    }

    order.status = 'voided';
    order.voidedAt = new Date();
    order.voidedBy = req.user._id;
    order.voidReason = voidReason || 'No reason provided';
    
    await order.save();

    res.json({ message: 'Order voided successfully', order });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  createOrder,
  getAllOrders,
  getMyOrders,
  getOrderById,
  voidOrder,
};
