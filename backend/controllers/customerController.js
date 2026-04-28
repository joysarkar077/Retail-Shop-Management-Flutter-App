const Customer = require('../models/Customer');
const Order = require('../models/Order');

const searchByPhone = async (req, res) => {
  const { phone } = req.query;
  const shopId = req.user.shopId;

  if (!phone) {
    return res.status(400).json({ message: 'Phone number is required' });
  }

  try {
    const customer = await Customer.findOne({ shopId, phoneNumber: phone });
    if (!customer) {
      return res.status(404).json({ message: 'Customer not found' });
    }
    res.json(customer);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const createCustomer = async (req, res) => {
  const { name, phoneNumber } = req.body;
  const shopId = req.user.shopId;

  try {
    const existing = await Customer.findOne({ shopId, phoneNumber });
    if (existing) {
      return res.status(400).json({ message: 'Customer with this phone already exists' });
    }

    const customer = await Customer.create({
      shopId,
      name,
      phoneNumber,
    });
    res.status(201).json(customer);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getShopCustomers = async (req, res) => {
  const shopId = req.user.shopId;

  try {
    const customers = await Customer.find({ shopId }).sort('-createdAt');
    res.json(customers);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getCustomerHistory = async (req, res) => {
  const { id } = req.params;
  const shopId = req.user.shopId;

  try {
    const customer = await Customer.findOne({ _id: id, shopId });
    if (!customer) return res.status(404).json({ message: 'Customer not found' });

    const orders = await Order.find({ customerId: id, shopId }).sort('-transactionDate');
    res.json({ customer, orders });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  searchByPhone,
  createCustomer,
  getShopCustomers,
  getCustomerHistory,
};
