const User = require('../models/User');
const { generateToken } = require('../middleware/auth');

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

    const token = generateToken({ role: 'admin' });

    res.json({ message: 'Admin login successful', token, role: 'admin' });
  } catch (error) {
    console.error('ADMIN LOGIN ERROR:', error);
    res.status(500).json({ message: 'Login failed', error: error.message });
  }
};

const getAllTenants = async (req, res) => {
  try {
    const tenants = await User.find({}, 'name mobile floor room roomType flat paymentStatus email');
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