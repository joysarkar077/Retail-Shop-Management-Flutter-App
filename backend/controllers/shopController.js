const Shop = require('../models/Shop');
const User = require('../models/User');
const bcrypt = require('bcryptjs');

const createShop = async (req, res) => {
  const { name, address, ownerName, ownerEmail, ownerPassword } = req.body;

  if (!name || !ownerName || !ownerEmail || !ownerPassword) {
    return res.status(400).json({ message: 'Please provide shop name and complete owner details.' });
  }

  try {
    // 1. Check if owner email already exists
    const userExists = await User.findOne({ email: ownerEmail });
    if (userExists) {
      return res.status(400).json({ message: 'An account with this Owner Email already exists.' });
    }

    // 2. Create the Shop
    const shop = await Shop.create({
      name,
      address,
    });

    // 3. Create the Owner User dynamically mapped to the new Shop
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(ownerPassword, salt);

    const owner = await User.create({
      name: ownerName,
      email: ownerEmail,
      password: hashedPassword,
      role: 'owner',
      shopId: shop._id,
      createdBy: req.user._id, // Track who explicitly created them
      isActive: true,
    });

    res.status(201).json({
      shop,
      owner: {
        _id: owner._id,
        name: owner.name,
        email: owner.email,
        role: owner.role
      }
    });

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

const updateShop = async (req, res) => {
  const { id } = req.params;
  const { name } = req.body;

  if (!name) return res.status(400).json({ message: 'Shop name is required.' });

  try {
    const shop = await Shop.findByIdAndUpdate(id, { name }, { new: true });
    if (!shop) return res.status(404).json({ message: 'Shop not found.' });
    
    res.json(shop);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  createShop,
  getAllShops,
  updateShop,
};
