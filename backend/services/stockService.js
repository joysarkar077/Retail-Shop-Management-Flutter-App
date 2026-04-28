const Product = require('../models/Product');
const StockLog = require('../models/StockLog');

const adjustStockLogic = async (productId, shopId, userId, quantityChanged, changeType, note = '') => {
  const product = await Product.findOne({ _id: productId, shopId: shopId });

  if (!product) {
    throw new Error('Product not found or access denied');
  }

  const quantityBefore = product.stock_count;
  const quantityAfter = quantityBefore + quantityChanged;

  if (quantityAfter < 0) {
    throw new Error('Stock cannot go below 0');
  }

  product.stock_count = quantityAfter;
  await product.save();

  const stockLog = await StockLog.create({
    productId: product._id,
    shopId: shopId,
    changeType,
    quantityBefore,
    quantityChanged,
    quantityAfter,
    note,
    performedBy: userId,
  });

  return { product, stockLog };
};

const deductStock = async (productId, quantity, shopId, userId, orderId) => {
  return await adjustStockLogic(productId, shopId, userId, -quantity, 'sale', `Sale - Order ${orderId}`);
};

const restoreStock = async (productId, quantity, shopId, userId, orderId) => {
  return await adjustStockLogic(productId, shopId, userId, quantity, 'void_restore', `Void - Order ${orderId}`);
};

module.exports = {
  adjustStockLogic,
  deductStock,
  restoreStock,
};
