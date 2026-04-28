const mongoose = require('mongoose');

const customerSchema = new mongoose.Schema({
  shopId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Shop',
    required: true,
  },
  phoneNumber: {
    type: String,
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  totalSpent: {
    type: Number,
    default: 0,
  },
  visitCount: {
    type: Number,
    default: 0,
  },
}, {
  timestamps: true,
});

// Ensure phone numbers are unique per shop
customerSchema.index({ shopId: 1, phoneNumber: 1 }, { unique: true });

const Customer = mongoose.model('Customer', customerSchema);
module.exports = Customer;
