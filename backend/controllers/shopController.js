const Shop = require('../models/Shop');

const createShop = async (req, res) => {
  const { name, address } = req.body;

  try {
    const shop = await Shop.create({
      name,
      address,
    });
    res.status(201).json(shop);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getAllShops = async (req, res) => {
  try {
    const shops = await Shop.find({ isActive: true }).sort('name');
    res.json(shops);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  createShop,
  getAllShops,
};
