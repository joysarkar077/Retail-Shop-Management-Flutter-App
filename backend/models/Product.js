const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  shopId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Shop',
    required: true,
  },
  categoryId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
  },
  name: {
    type: String,
    required: true,
  },
  sku: {
    type: String,
  },
  barcode: {
    type: String,
  },
  unit: {
    type: String,
    enum: ['kg', 'g', 'liter', 'ml', 'piece', 'packet', 'box', 'pcs', 'ltr', 'dozen', 'pack'],
    default: 'piece',
  },
  costPrice: {
    type: Number,
    default: 0,
  },
  sellingPrice: {
    type: Number,
    required: true,
  },
  stock_count: {
    type: Number,
    default: 0,
    required: true,
  },
  low_stock_threshold: {
    type: Number,
    default: 10,
  },
  imageUrl: {
    type: String,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
}, {
  timestamps: true,
});

const Product = mongoose.model('Product', productSchema);
module.exports = Product;
