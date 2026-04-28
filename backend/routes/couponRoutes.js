const express = require('express');
const router = express.Router();
const {
  applyCoupon,
  createCoupon,
  getCoupons,
  deleteCoupon,
} = require('../controllers/couponController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

router.post('/apply', verifyToken, applyCoupon);
router.post('/', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), createCoupon);
router.get('/', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), getCoupons);
router.delete('/:id', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), deleteCoupon);

module.exports = router;
