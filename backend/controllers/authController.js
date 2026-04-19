const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const registerUser = async (req, res) => {
  const { name, email, password, role, shopId } = req.body;

  try {
    const userExists = await User.findOne({ email });

    if (userExists) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Role-based validation (only specific roles can create other specific roles)
    const creatorRole = req.user.role;
    const allowedToCreate = {
      superadmin: ['admin', 'owner', 'manager', 'employee'],
      admin: ['owner', 'manager', 'employee'],
      owner: ['manager', 'employee'],
      manager: ['employee'],
      employee: []
    };

    if (!allowedToCreate[creatorRole].includes(role)) {
      return res.status(403).json({ message: 'Forbidden. You are not allowed to create a user with this role.' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      role,
      shopId: shopId || req.user.shopId, // Default to creator's shop if not provided
      createdBy: req.user._id,
    });

    if (user) {
      res.status(201).json({
        success: true,
        message: "User created.",
        user: {
          _id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,
          shopId: user.shopId,
        }
      });
    } else {
      res.status(400).json({ message: 'Invalid user data' });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user || (!user.isActive)) {
      return res.status(401).json({ message: 'Invalid email or password, or account inactive' });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    user.lastLogin = new Date();
    await user.save();

    const payload = {
      userId: user._id,
      role: user.role,
      shopId: user.shopId
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });

    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        role: user.role,
        shopId: user.shopId,
      }
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('-password');
    res.json(user);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const changePassword = async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  try {
    const user = await User.findById(req.user._id);

    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Current password is incorrect' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    user.password = hashedPassword;
    await user.save();

    res.json({ message: 'Password changed successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getUsersByShop = async (req, res) => {
  try {
    const users = await User.find({ shopId: req.params.shopId }).select('-password');
    res.json(users);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  registerUser,
  loginUser,
  getMe,
  changePassword,
  getUsersByShop,
};
