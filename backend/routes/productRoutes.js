const express = require('express');
const router = express.Router();
const {
  getAllProducts,
  getProductByBarcode,
  getProductById,
  addProduct,
  updateProduct,
  deleteProduct,
  getLowStockProducts,
} = require('../controllers/productController');
const { adjustStock, getStockLogs } = require('../controllers/stockController');
const { verifyToken, requireRole } = require('../middleware/authMiddleware');

router.get('/', verifyToken, getAllProducts);
router.get('/barcode/:code', verifyToken, getProductByBarcode);
router.get('/alerts/low-stock', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), getLowStockProducts);
router.get('/:id', verifyToken, getProductById);
router.post('/', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), addProduct);
router.put('/:id', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), updateProduct);
router.delete('/:id', verifyToken, requireRole('superadmin', 'admin', 'owner'), deleteProduct);

// Stock routes
router.patch('/:id/stock', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), adjustStock);
router.get('/:id/stock-logs', verifyToken, requireRole('superadmin', 'admin', 'owner', 'manager'), getStockLogs);

module.exports = router;
