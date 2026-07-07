const User = require('../models/User');

// @desc  Admin login (hardcoded from .env)
// @route POST /api/admin/login
const adminLogin = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ message: 'Username and password required' });
    }

    const validUsername = process.env.ADMIN_USERNAME;
    const validPassword = process.env.ADMIN_PASSWORD;

    if (username !== validUsername || password !== validPassword) {
      return res.status(401).json({ message: 'Invalid admin credentials' });
    }

    res.json({ message: 'Admin login successful', role: 'admin' });
  } catch (error) {
    console.error('ADMIN LOGIN ERROR:', error);
    res.status(500).json({ message: 'Login failed', error: error.message });
  }
};

// @desc  Get all tenants with count
// @route GET /api/admin/tenants
const getAllTenants = async (req, res) => {
  try {
    const tenants = await User.find({}, 'name mobile flat paymentStatus email');
    res.json({
      totalTenants: tenants.length,
      tenants,
    });
  } catch (error) {
    console.error('GET TENANTS ERROR:', error);
    res.status(500).json({ message: 'Failed to fetch tenants', error: error.message });
  }
};

module.exports = { adminLogin, getAllTenants };