const Product = require('../models/Product');

const getAllProducts = async (req, res) => {
  try {
    const shopId = req.user.shopId;
    const { category, search, lowStock, page = 1, limit = 20 } = req.query;

    let query = { shopId, isActive: true };

    if (category) {
      // Assumes we populate category or search by category ID (this handles string matching for simplicity, 
      // but in reality we should lookup categoryId if searching by category name)
      query.categoryId = category;
    }

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { sku: { $regex: search, $options: 'i' } },
      ];
    }

    if (lowStock === 'true') {
      // Find where stock_count <= low_stock_threshold
      query.$expr = { $lte: ['$stock_count', '$low_stock_threshold'] };
    }

    const skip = (page - 1) * limit;

    const products = await Product.find(query)
      .populate('categoryId', 'name')
      .skip(Number(skip))
      .limit(Number(limit))
      .sort('name');

    const total = await Product.countDocuments(query);

    res.json({
      products,
      page: Number(page),
      totalPages: Math.ceil(total / limit),
      totalProducts: total,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getProductByBarcode = async (req, res) => {
  const { code } = req.params;
  const shopId = req.user.shopId;

  try {
    const product = await Product.findOne({ barcode: code, shopId, isActive: true }).populate('categoryId', 'name');
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    res.json(product);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getProductById = async (req, res) => {
  const { id } = req.params;
  const shopId = req.user.shopId;

  try {
    const product = await Product.findOne({ _id: id, shopId, isActive: true }).populate('categoryId', 'name');
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }
    res.json(product);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const addProduct = async (req, res) => {
  const shopId = req.user.shopId;
  const { categoryId, name, sku, barcode, unit, costPrice, sellingPrice, stock_count, low_stock_threshold, imageUrl } = req.body;

  try {
    const product = await Product.create({
      shopId,
      categoryId,
      name,
      sku,
      barcode,
      unit,
      costPrice,
      sellingPrice,
      stock_count,
      low_stock_threshold,
      imageUrl, // Assume Cloudinary URL is passed here
      createdBy: req.user._id,
    });

    res.status(201).json(product);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const updateProduct = async (req, res) => {
  const { id } = req.params;
  const shopId = req.user.shopId;
  const { categoryId, name, sku, barcode, unit, costPrice, sellingPrice, stock_count, low_stock_threshold, imageUrl } = req.body;

  try {
    const product = await Product.findOne({ _id: id, shopId });

    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    product.categoryId = categoryId || product.categoryId;
    product.name = name || product.name;
    product.sku = sku || product.sku;
    product.barcode = barcode || product.barcode;
    product.unit = unit || product.unit;
    product.costPrice = costPrice !== undefined ? costPrice : product.costPrice;
    product.sellingPrice = sellingPrice !== undefined ? sellingPrice : product.sellingPrice;
    product.stock_count = stock_count !== undefined ? stock_count : product.stock_count;
    product.low_stock_threshold = low_stock_threshold !== undefined ? low_stock_threshold : product.low_stock_threshold;
    product.imageUrl = imageUrl || product.imageUrl;

    await product.save();

    res.json(product);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const deleteProduct = async (req, res) => {
  const { id } = req.params;
  const shopId = req.user.shopId;

  try {
    const product = await Product.findOne({ _id: id, shopId });

    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    product.isActive = false;
    await product.save();

    res.json({ message: 'Product deleted smoothly (soft delete)' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getLowStockProducts = async (req, res) => {
  const shopId = req.user.shopId;

  try {
    // Return all products below threshold
    const products = await Product.find({
      shopId,
      isActive: true,
      $expr: { $lte: ['$stock_count', '$low_stock_threshold'] }
    }).sort({ stock_count: 1 }); // Lowest stock first

    res.json(products);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  getAllProducts,
  getProductByBarcode,
  getProductById,
  addProduct,
  updateProduct,
  deleteProduct,
  getLowStockProducts,
};
