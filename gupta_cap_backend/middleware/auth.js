const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'gupta_capitals_jwt_secret_key_2026';

const generateToken = (payload, expiresIn = '30d') => {
  return jwt.sign(payload, JWT_SECRET, { expiresIn });
};

const verifyToken = (req, res, next) => {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Access denied. No token provided.' });
  }

  const token = header.split(' ')[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};

const adminOnly = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    return next();
  }
  return res.status(403).json({ message: 'Access denied. Admin only.' });
};

module.exports = { generateToken, verifyToken, adminOnly };
