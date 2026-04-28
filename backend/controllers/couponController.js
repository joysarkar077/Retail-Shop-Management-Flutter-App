const Coupon = require('../models/Coupon');

const applyCoupon = async (req, res) => {
  const { code } = req.body;
  const shopId = req.user.shopId;

  if (!code) {
    return res.status(400).json({ message: 'Coupon code is required' });
  }

  try {
    const coupon = await Coupon.findOne({ shopId, code: code.toUpperCase(), isActive: true });
    if (!coupon) {
      return res.status(404).json({ message: 'Invalid or expired coupon' });
    }
    res.json(coupon);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const createCoupon = async (req, res) => {
  const { code, discountPercentage } = req.body;
  const shopId = req.user.shopId;

  try {
    const existing = await Coupon.findOne({ shopId, code: code.toUpperCase() });
    if (existing) {
      return res.status(400).json({ message: 'Coupon with this code already exists' });
    }

    const coupon = await Coupon.create({
      shopId,
      code,
      discountPercentage,
    });
    res.status(201).json(coupon);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const getCoupons = async (req, res) => {
  const shopId = req.user.shopId;

  try {
    const coupons = await Coupon.find({ shopId }).sort('-createdAt');
    res.json(coupons);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const deleteCoupon = async (req, res) => {
  const { id } = req.params;
  const shopId = req.user.shopId;

  try {
    const coupon = await Coupon.findOneAndDelete({ _id: id, shopId });
    if (!coupon) {
      return res.status(404).json({ message: 'Coupon not found' });
    }
    res.json({ message: 'Coupon deleted' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = {
  applyCoupon,
  createCoupon,
  getCoupons,
  deleteCoupon,
};
