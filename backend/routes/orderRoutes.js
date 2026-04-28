const express = require('express');
const router = express.Router();
const { createOrder, getAllOrders, getMyOrders, getOrderById, voidOrder } = require('../controllers/orderController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

router.post('/', verifyToken, createOrder); // All authenticated roles
router.get('/', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), getAllOrders);
router.get('/my', verifyToken, getMyOrders); // Employee can see their own orders
router.get('/:id', verifyToken, getOrderById);
router.patch('/:id/void', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), voidOrder);

module.exports = router;
