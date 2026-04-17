const express = require('express');
const router = express.Router();
const {
  registerUser,
  loginUser,
  getMe,
  changePassword,
} = require('../controllers/authController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

router.post('/login', loginUser);
router.post('/register', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), registerUser);
router.get('/me', verifyToken, getMe);
router.patch('/change-password', verifyToken, changePassword);

module.exports = router;
