require('dotenv').config({ path: __dirname + '/../.env' });
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Shop = require('../models/Shop');

const seedUsers = async () => {
  try {
    if (!process.env.MONGO_URI) {
      console.log('Error: MONGO_URI is not set in .env');
      process.exit(1);
    }

    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB Connected for Seeding');

    // Create a dummy shop for roles that require a shop
    let shop = await Shop.findOne({ name: 'Test Shop' });
    if (!shop) {
      shop = await Shop.create({
        name: 'Test Shop',
        address: '123 Fake Street',
      });
    }

    const usersToCreate = [
      { email: 'sadmin@shopjs.com', role: 'superadmin', name: 'Super Admin', shopId: null },
      { email: 'admin@shopjs.com', role: 'admin', name: 'System Admin', shopId: null },
      { email: 'owner@shopjs.com', role: 'owner', name: 'Shop Owner', shopId: shop._id },
      { email: 'manager@shopjs.com', role: 'manager', name: 'Store Manager', shopId: shop._id },
      { email: 'employee@shopjs.com', role: 'employee', name: 'Sales Employee', shopId: shop._id },
    ];

    for (const userData of usersToCreate) {
      const exists = await User.findOne({ email: userData.email });
      if (!exists) {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(userData.email, salt); // Password same as email

        await User.create({
          name: userData.name,
          email: userData.email,
          password: hashedPassword,
          role: userData.role,
          shopId: userData.shopId,
          isActive: true,
        });
        console.log(`Created: ${userData.email} | Role: ${userData.role}`);
      } else {
        console.log(`Skipped (Already exists): ${userData.email}`);
      }
    }

    console.log('All test users seeded successfully!');
    process.exit();
  } catch (error) {
    console.error('Seeding error:', error);
    process.exit(1);
  }
};

seedUsers();
