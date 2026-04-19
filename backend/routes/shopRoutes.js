const express = require('express');
const router = express.Router();
const { createShop, getAllShops, updateShop } = require('../controllers/shopController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

router.get('/', verifyToken, requireRole('superadmin', 'admin'), getAllShops);
router.post('/', verifyToken, requireRole('superadmin', 'admin'), createShop);
router.put('/:id', verifyToken, requireRole('superadmin', 'admin'), updateShop);

module.exports = router;
