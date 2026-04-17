const { adjustStockLogic } = require('../services/stockService');
const StockLog = require('../models/StockLog');
const Product = require('../models/Product');

const adjustStock = async (req, res) => {
  const { id } = req.params;
  const { quantityChanged, changeType, note } = req.body;
  const shopId = req.user.shopId;
  const userId = req.user._id;

  try {
    const result = await adjustStockLogic(id, shopId, userId, quantityChanged, changeType, note);
    res.json({ message: 'Stock adjusted successfully', product: result.product });
  } catch (error) {
    console.error(error);
    res.status(400).json({ message: error.message });
  }
};

const getStockLogs = async (req, res) => {
  const { id } = req.params;
  const shopId = req.user.shopId;

  try {
    const product = await Product.findOne({ _id: id, shopId });
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const logs = await StockLog.find({ productId: id, shopId }).sort({ createdAt: -1 }).populate('performedBy', 'name email');
    res.json(logs);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  adjustStock,
  getStockLogs,
};
