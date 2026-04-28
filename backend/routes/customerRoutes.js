const express = require('express');
const router = express.Router();
const {
  searchByPhone,
  createCustomer,
  getShopCustomers,
  getCustomerHistory,
} = require('../controllers/customerController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

router.get('/search', verifyToken, searchByPhone);
router.post('/', verifyToken, createCustomer);
router.get('/', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), getShopCustomers);
router.get('/:id/history', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), getCustomerHistory);

module.exports = router;
