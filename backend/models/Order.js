const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true,
  },
  productName: {
    type: String,
    required: true,
  },
  productSku: {
    type: String,
  },
  unitPrice: {
    type: Number,
    required: true,
  },
  quantity: {
    type: Number,
    required: true,
  },
  unit: {
    type: String,
    required: true,
  },
  lineTotal: {
    type: Number,
    required: true,
  },
});

const orderSchema = new mongoose.Schema({
  shopId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Shop',
    required: true,
  },
  invoiceNumber: {
    type: String,
    required: true,
    unique: true,
  },
  staffId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Customer',
  },
  customerPhone: {
    type: String,
  },
  customerName: {
    type: String,
    default: 'Walk-in Customer',
  },
  paymentMethod: {
    type: String,
    enum: ['cash', 'card', 'mobile'],
    required: true,
  },
  status: {
    type: String,
    enum: ['completed', 'voided'],
    default: 'completed',
  },
  items: [orderItemSchema],
  subtotal: {
    type: Number,
    required: true,
  },
  taxAmount: {
    type: Number,
    required: true,
  },
  discountAmount: {
    type: Number,
    default: 0,
  },
  totalAmount: {
    type: Number,
    required: true,
  },
  voidedAt: {
    type: Date,
    default: null,
  },
  voidedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null,
  },
  voidReason: {
    type: String,
  },
}, {
  timestamps: { createdAt: 'transactionDate', updatedAt: true },
});

const Order = mongoose.model('Order', orderSchema);
module.exports = Order;
