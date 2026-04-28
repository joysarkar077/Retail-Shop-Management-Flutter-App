require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('./models/Product');
const Shop = require('./models/Shop');

const seedProducts = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB Connected');

    // Find the ABC Shop
    const shop = await Shop.findOne({ name: /ABC Shop/i });
    if (!shop) {
      console.log('Error: ABC Shop not found.');
      process.exit(1);
    }
    const shopId = shop._id;

    // Define the new products
    const products = [
      {
        shopId,
        name: 'Bashmati Rice',
        sku: 'ABC00003',
        barcode: 'ABC00003',
        unit: 'kg',
        costPrice: 180,
        sellingPrice: 200,
        stock_count: 50,
        low_stock_threshold: 10,
        isActive: true,
      },
      {
        shopId,
        name: 'Salt',
        sku: 'ABC00004',
        barcode: 'ABC00004',
        unit: 'kg',
        costPrice: 100,
        sellingPrice: 120,
        stock_count: 100,
        low_stock_threshold: 20,
        isActive: true,
      },
      {
        shopId,
        name: 'Soybean Oil',
        sku: 'ABC00005',
        barcode: 'ABC00005',
        unit: 'liter',
        costPrice: 160,
        sellingPrice: 170,
        stock_count: 40,
        low_stock_threshold: 5,
        isActive: true,
      },
      {
        shopId,
        name: 'Lentils (Masoor Dal)',
        sku: 'ABC00006',
        barcode: 'ABC00006',
        unit: 'kg',
        costPrice: 120,
        sellingPrice: 140,
        stock_count: 30,
        low_stock_threshold: 10,
        isActive: true,
      },
      {
        shopId,
        name: 'Onion',
        sku: 'ABC00007',
        barcode: 'ABC00007',
        unit: 'kg',
        costPrice: 60,
        sellingPrice: 80,
        stock_count: 60,
        low_stock_threshold: 15,
        isActive: true,
      },
      {
        shopId,
        name: 'Sugar',
        sku: 'ABC00008',
        barcode: 'ABC00008',
        unit: 'kg',
        costPrice: 110,
        sellingPrice: 130,
        stock_count: 80,
        low_stock_threshold: 20,
        isActive: true,
      }
    ];

    for (let pData of products) {
      // Check if product already exists to avoid duplicates
      const exists = await Product.findOne({ sku: pData.sku, shopId: shopId });
      if (!exists) {
        await Product.create(pData);
        console.log(`Added: ${pData.name}`);
      } else {
        console.log(`Skipped (already exists): ${pData.name}`);
      }
    }

    console.log('Seeding complete!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding products:', error);
    process.exit(1);
  }
};

seedProducts();
