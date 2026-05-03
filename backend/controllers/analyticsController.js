const Order = require('../models/Order');
const mongoose = require('mongoose');

const getDateRange = (period) => {
  const end = new Date();
  const start = new Date();
  if (period === 'today') {
    start.setHours(0, 0, 0, 0);
  } else if (period === 'week') {
    start.setDate(end.getDate() - 7);
  } else if (period === 'month') {
    start.setMonth(end.getMonth() - 1);
  } else {
    // Default to last 30 days
    start.setDate(end.getDate() - 30);
  }
  return { start, end };
};

const getSummary = async (req, res) => {
  const shopId = (['superadmin', 'admin'].includes(req.user.role) && req.query.shopId) ? req.query.shopId : req.user.shopId;
  const { period = 'today' } = req.query;
  const { start, end } = getDateRange(period);

  try {
    const matchStage = { shopId: new mongoose.Types.ObjectId(shopId.toString()), status: 'completed', transactionDate: { $gte: start, $lte: end } };
    if (req.user.role === 'employee') {
      matchStage.staffId = new mongoose.Types.ObjectId(req.user._id.toString());
    }

    const result = await Order.aggregate([
      { $match: matchStage },
      { $group: {
          _id: null,
          totalRevenue: { $sum: "$totalAmount" },
          orderCount: { $sum: 1 }
      }}
    ]);

    if (result.length > 0) {
      const { totalRevenue, orderCount } = result[0];
      const avgOrderValue = orderCount > 0 ? totalRevenue / orderCount : 0;
      res.json({ totalRevenue, orderCount, avgOrderValue });
    } else {
      res.json({ totalRevenue: 0, orderCount: 0, avgOrderValue: 0 });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getRevenueSeries = async (req, res) => {
  const shopId = (['superadmin', 'admin'].includes(req.user.role) && req.query.shopId) ? req.query.shopId : req.user.shopId;
  const { period = 'week' } = req.query;
  const { start, end } = getDateRange(period);

  try {
    const series = await Order.aggregate([
      { $match: { shopId: new mongoose.Types.ObjectId(shopId.toString()), status: 'completed', transactionDate: { $gte: start, $lte: end } } },
      { $group: {
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$transactionDate" } },
          revenue: { $sum: "$totalAmount" },
          orderCount: { $sum: 1 }
      }},
      { $sort: { _id: 1 } }
    ]);
    res.json(series.map(s => ({ date: s._id, revenue: s.revenue, orderCount: s.orderCount })));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getTopProducts = async (req, res) => {
  const shopId = (['superadmin', 'admin'].includes(req.user.role) && req.query.shopId) ? req.query.shopId : req.user.shopId;
  const limit = parseInt(req.query.limit) || 5;

  try {
    const products = await Order.aggregate([
      { $match: { shopId: new mongoose.Types.ObjectId(shopId.toString()), status: 'completed' } },
      { $unwind: "$items" },
      { $group: {
          _id: "$items.productName",
          totalQty: { $sum: "$items.quantity" },
          totalRevenue: { $sum: "$items.lineTotal" }
      }},
      { $sort: { totalRevenue: -1 } },
      { $limit: limit }
    ]);
    res.json(products);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getPaymentBreakdown = async (req, res) => {
  const shopId = (['superadmin', 'admin'].includes(req.user.role) && req.query.shopId) ? req.query.shopId : req.user.shopId;
  const { period = 'month' } = req.query;
  const { start, end } = getDateRange(period);

  try {
    const breakdown = await Order.aggregate([
      { $match: { shopId: new mongoose.Types.ObjectId(shopId.toString()), status: 'completed', transactionDate: { $gte: start, $lte: end } } },
      { $group: {
          _id: "$paymentMethod",
          revenue: { $sum: "$totalAmount" },
          count: { $sum: 1 }
      }},
      { $sort: { revenue: -1 } }
    ]);
    res.json(breakdown.map(b => ({ method: b._id, revenue: b.revenue, count: b.count })));
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  getSummary,
  getRevenueSeries,
  getTopProducts,
  getPaymentBreakdown,
};
