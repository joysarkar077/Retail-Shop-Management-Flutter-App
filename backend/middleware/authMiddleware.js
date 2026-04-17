const jwt = require('jsonwebtoken');
const User = require('../models/User');

const verifyToken = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      req.user = await User.findById(decoded.userId).select('-password');
      
      if (!req.user || !req.user.isActive) {
        return res.status(401).json({ message: 'Not authorized, user inactive or not found' });
      }
      
      next();
    } catch (error) {
      console.error(error);
      res.status(401).json({ message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    res.status(401).json({ message: 'Not authorized, no token' });
  }
};

const requireRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ message: 'Forbidden, insufficient permissions' });
    }
    next();
  };
};

const requireSameShop = (req, res, next) => {
  // If the user is superadmin or admin, they bypass the same shop check (can access anything)
  if (req.user.role === 'superadmin' || req.user.role === 'admin') {
    return next();
  }

  // ShopId check: we assume the route usually has a shopId parameter,
  // or it implicitly uses req.user.shopId for the queries.
  // This middleware can be adapted based on specific routes.
  // For now, it enforces that req.user.shopId exists.
  if (!req.user.shopId) {
    return res.status(403).json({ message: 'Forbidden, shop context missing' });
  }

  // We can validate if a body/params shopId matches the user's shopId if provided in request
  const requestShopId = req.params.shopId || req.body.shopId || req.query.shopId;
  if (requestShopId && requestShopId !== req.user.shopId.toString()) {
    return res.status(403).json({ message: 'Forbidden, cannot access other shop data' });
  }

  next();
};

module.exports = { verifyToken, requireRole, requireSameShop };
