const express = require('express');
const router = express.Router();
const {
  registerUser,
  loginUser,
  getMe,
  changePassword,
  getUsersByShop,
} = require('../controllers/authController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

router.post('/login', loginUser);
router.post('/register', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), registerUser);
router.get('/me', verifyToken, getMe);
router.patch('/change-password', verifyToken, changePassword);
router.get('/shop/:shopId/users', verifyToken, requireRole('superadmin', 'admin'), getUsersByShop);

module.exports = router;
