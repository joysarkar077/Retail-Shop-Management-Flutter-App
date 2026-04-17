const express = require('express');
const router = express.Router();
const {
  getAllCategories,
  createCategory,
  updateCategory,
  deleteCategory,
} = require('../controllers/categoryController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

router.get('/', verifyToken, getAllCategories);
router.post('/', verifyToken, requireRole('superadmin', 'admin', 'owner'), createCategory);
router.put('/:id', verifyToken, requireRole('superadmin', 'admin', 'owner'), updateCategory);
router.delete('/:id', verifyToken, requireRole('superadmin', 'admin', 'owner'), deleteCategory);

module.exports = router;
