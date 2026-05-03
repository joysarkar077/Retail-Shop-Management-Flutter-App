const express = require('express');
const router = express.Router();
const { getSummary, getRevenueSeries, getTopProducts, getPaymentBreakdown } = require('../controllers/analyticsController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

const allowedRoles = requireRole('superadmin', 'admin', 'owner', 'manager');

router.get('/summary', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager', 'employee'), getSummary);
router.get('/revenue', verifyToken, allowedRoles, getRevenueSeries);
router.get('/top-products', verifyToken, allowedRoles, getTopProducts);
router.get('/payment-methods', verifyToken, requireRole('superadmin', 'admin', 'owner'), getPaymentBreakdown);

module.exports = router;
