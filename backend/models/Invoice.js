const mongoose = require('mongoose');

const invoiceSchema = new mongoose.Schema({
  orderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: true,
    unique: true,
  },
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
}, {
  timestamps: { createdAt: 'issuedAt', updatedAt: false },
});

const Invoice = mongoose.model('Invoice', invoiceSchema);
module.exports = Invoice;
