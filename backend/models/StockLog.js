const mongoose = require('mongoose');

const stockLogSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true,
  },
  shopId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Shop',
    required: true,
  },
  changeType: {
    type: String,
    enum: ['sale', 'restock', 'adjustment', 'damage', 'opening', 'void_restore'],
    required: true,
  },
  quantityBefore: {
    type: Number,
    required: true,
  },
  quantityChanged: {
    type: Number,
    required: true,
  },
  quantityAfter: {
    type: Number,
    required: true,
  },
  note: {
    type: String,
  },
  performedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
}, {
  timestamps: true, // timestamp serves as the time of the change
});

const StockLog = mongoose.model('StockLog', stockLogSchema);
module.exports = StockLog;
