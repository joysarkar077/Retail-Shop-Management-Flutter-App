require('dotenv').config({ path: __dirname + '/../.env' });
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');

const seedSuperAdmin = async () => {
  try {
    if (!process.env.MONGO_URI) {
      console.log('Error: MONGO_URI is not set in .env');
      process.exit(1);
    }

    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB Connected for Seeding');

    const adminExists = await User.findOne({ email: 'joysarkar.bracu@gmail.com' });
    if (adminExists) {
      console.log('SuperAdmin already exists!');
      process.exit();
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('joysarkar.bracu@gmail.com', salt); // Password same as email

    await User.create({
      name: 'Joy Sarkar SuperAdmin',
      email: 'joysarkar.bracu@gmail.com',
      password: hashedPassword,
      role: 'superadmin',
      shopId: null, // superadmin doesn't belong to a specific shop
      isActive: true,
    });

    console.log('SuperAdmin seeded successfully! Email: joysarkar.bracu@gmail.com | Password: joysarkar.bracu@gmail.com');
    process.exit();
  } catch (error) {
    console.error('Seeding error:', error);
    process.exit(1);
  }
};

seedSuperAdmin();
