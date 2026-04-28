const express = require('express');
const router = express.Router();
const { createShop, getAllShops, getShopById, updateShop } = require('../controllers/shopController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

router.get('/', verifyToken, requireRole('superadmin', 'admin'), getAllShops);
router.get('/:id', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), getShopById);
router.post('/', verifyToken, requireRole('superadmin', 'admin'), createShop);
router.put('/:id', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), updateShop);

module.exports = router;
