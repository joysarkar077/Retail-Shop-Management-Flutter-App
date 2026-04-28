require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('./models/Product');
const Shop = require('./models/Shop');
const User = require('./models/User');
const Customer = require('./models/Customer');
const Order = require('./models/Order');
const Invoice = require('./models/Invoice');
const { generateInvoiceNumber } = require('./services/invoiceNumberService');

const seedData = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB Connected');

    const shop = await Shop.findOne({ name: /ABC Shop/i });
    if (!shop) {
      console.log('Error: ABC Shop not found.');
      process.exit(1);
    }
    const shopId = shop._id;

    const staff = await User.findOne({ shopId: shopId });
    if (!staff) {
      console.log('Error: No staff found for ABC Shop.');
      process.exit(1);
    }
    const staffId = staff._id;

    // More Products
    const newProductsData = [
      { shopId, name: 'Radhuni Halim Mix', sku: 'ABC00009', barcode: 'ABC00009', unit: 'pack', costPrice: 40, sellingPrice: 55, stock_count: 50, isActive: true },
      { shopId, name: 'Maggi Noodles 8-pack', sku: 'ABC00010', barcode: 'ABC00010', unit: 'pack', costPrice: 120, sellingPrice: 140, stock_count: 100, isActive: true },
      { shopId, name: 'Ispahani Mirzapore Tea', sku: 'ABC00011', barcode: 'ABC00011', unit: 'pack', costPrice: 200, sellingPrice: 220, stock_count: 40, isActive: true },
      { shopId, name: 'Pran Mango Juice 1L', sku: 'ABC00012', barcode: 'ABC00012', unit: 'liter', costPrice: 80, sellingPrice: 100, stock_count: 60, isActive: true },
      { shopId, name: 'Bombay Sweets Potato Crackers', sku: 'ABC00013', barcode: 'ABC00013', unit: 'pack', costPrice: 10, sellingPrice: 15, stock_count: 200, isActive: true },
      { shopId, name: 'Aarong Dairy Liquid Milk', sku: 'ABC00014', barcode: 'ABC00014', unit: 'liter', costPrice: 80, sellingPrice: 90, stock_count: 50, isActive: true },
    ];

    const insertedProducts = [];
    for (let p of newProductsData) {
      let existing = await Product.findOne({ sku: p.sku, shopId });
      if (!existing) {
        existing = await Product.create(p);
        console.log(`Added product: ${p.name}`);
      } else {
        console.log(`Product already exists: ${p.name}`);
      }
      insertedProducts.push(existing);
    }

    // Add Customers
    const newCustomersData = [
      { shopId, name: 'Rahim Uddin', phoneNumber: '01711111111', totalSpent: 0, visitCount: 0 },
      { shopId, name: 'Karim Hasan', phoneNumber: '01822222222', totalSpent: 0, visitCount: 0 },
      { shopId, name: 'Sadia Islam', phoneNumber: '01933333333', totalSpent: 0, visitCount: 0 },
      { shopId, name: 'Fatema Begum', phoneNumber: '01644444444', totalSpent: 0, visitCount: 0 },
    ];

    const insertedCustomers = [];
    for (let c of newCustomersData) {
      let existing = await Customer.findOne({ phoneNumber: c.phoneNumber, shopId });
      if (!existing) {
        existing = await Customer.create(c);
        console.log(`Added customer: ${c.name}`);
      } else {
        console.log(`Customer already exists: ${c.name}`);
      }
      insertedCustomers.push(existing);
    }

    // Add Orders
    console.log('Generating orders...');
    const allProducts = await Product.find({ shopId });
    
    // We'll generate 6 orders randomly
    for (let i=0; i<6; i++) {
      const customer = insertedCustomers[i % insertedCustomers.length];
      
      const orderItems = [];
      let subtotal = 0;
      
      const p1 = allProducts[Math.floor(Math.random() * allProducts.length)];
      const p2 = allProducts[Math.floor(Math.random() * allProducts.length)];
      
      const qty1 = Math.floor(Math.random() * 4) + 1;
      const qty2 = Math.floor(Math.random() * 3) + 1;

      orderItems.push({
        productId: p1._id, productName: p1.name, productSku: p1.sku,
        unitPrice: p1.sellingPrice, quantity: qty1, unit: p1.unit,
        lineTotal: p1.sellingPrice * qty1
      });
      subtotal += (p1.sellingPrice * qty1);

      if (p1._id.toString() !== p2._id.toString()) {
        orderItems.push({
          productId: p2._id, productName: p2.name, productSku: p2.sku,
          unitPrice: p2.sellingPrice, quantity: qty2, unit: p2.unit,
          lineTotal: p2.sellingPrice * qty2
        });
        subtotal += (p2.sellingPrice * qty2);
      }

      const taxAmount = subtotal * 0.05;
      const totalAmount = subtotal + taxAmount;
      const invoiceNumber = await generateInvoiceNumber();

      const order = await Order.create({
        shopId,
        invoiceNumber,
        staffId,
        customerId: customer._id,
        customerName: customer.name,
        customerPhone: customer.phoneNumber,
        paymentMethod: i % 2 === 0 ? 'cash' : 'card',
        items: orderItems,
        subtotal,
        taxAmount,
        discountAmount: 0,
        totalAmount,
        // Set some random past dates to make charts look interesting
        transactionDate: new Date(Date.now() - Math.floor(Math.random() * 10) * 24 * 60 * 60 * 1000)
      });

      // Update customer stats
      customer.totalSpent += totalAmount;
      customer.visitCount += 1;
      await customer.save();

      // Create invoice
      await Invoice.create({
        orderId: order._id,
        shopId,
        invoiceNumber
      });

      console.log(`Created Order ${invoiceNumber} for ${customer.name} (Total: ৳${totalAmount.toFixed(2)})`);
    }

    console.log('Seeding complete!');
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

seedData();
