require('dotenv').config();
const mongoose = require('mongoose');
const Order = require('../models/Order');
const Invoice = require('../models/Invoice');
const Product = require('../models/Product');
const User = require('../models/User');
const { generateInvoiceNumber } = require('../services/invoiceNumberService');

async function seed() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to DB');

    const user = await User.findOne({ email: 'employee@shopjs.com' });
    if (!user) {
      console.log('User not found');
      process.exit(1);
    }

    const shopId = user.shopId;
    const products = await Product.find({ shopId, isActive: true }).limit(5);

    if (products.length === 0) {
      console.log('No products found for this shop');
      process.exit(1);
    }

    // Create 10 transactions over the last 7 days
    for (let i = 0; i < 10; i++) {
      const date = new Date();
      date.setDate(date.getDate() - Math.floor(Math.random() * 7));
      date.setHours(Math.floor(Math.random() * 24), Math.floor(Math.random() * 60));

      const invoiceNumber = await generateInvoiceNumber();
      
      // Pick 1-3 random products
      const itemsCount = Math.floor(Math.random() * 3) + 1;
      const items = [];
      let subtotal = 0;

      for (let j = 0; j < itemsCount; j++) {
        const p = products[Math.floor(Math.random() * products.length)];
        const qty = Math.floor(Math.random() * 5) + 1;
        const lineTotal = p.sellingPrice * qty;
        subtotal += lineTotal;

        items.push({
          productId: p._id,
          productName: p.name,
          productSku: p.sku,
          unitPrice: p.sellingPrice,
          quantity: qty,
          unit: p.unit,
          lineTotal
        });
      }

      const taxAmount = subtotal * 0.05;
      const totalAmount = subtotal + taxAmount;

      const order = await Order.create({
        shopId,
        invoiceNumber,
        staffId: user._id,
        customerName: 'Seed Customer ' + (i + 1),
        paymentMethod: ['cash', 'card', 'mobile'][Math.floor(Math.random() * 3)],
        items,
        subtotal,
        taxAmount,
        totalAmount,
        transactionDate: date
      });

      await Invoice.create({
        orderId: order._id,
        shopId,
        invoiceNumber
      });

      console.log(`Created Order ${invoiceNumber}`);
    }

    console.log('Seeding complete');
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
}

seed();
