const User = require('../models/User');
const { generateToken } = require('../middleware/auth');
const RentConfig = require('../models/RentConfig');
const PaymentRequest = require('../models/PaymentRequest');

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

const getAllUsers = async (req, res) => {
  try {
    const users = await User.find({}, 'name mobile floor room roomType flat paymentStatus email');
    res.json({
      totalUsers: users.length,
      users,
    });
  } catch (error) {
    console.error('GET USERS ERROR:', error);
    res.status(500).json({ message: 'Failed to fetch users', error: error.message });
  }
};

// @route DELETE /api/admin/users/:userId
const deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    await User.findByIdAndDelete(userId);
    await RentConfig.deleteMany({ userId });
    await PaymentRequest.deleteMany({ userId });

    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('DELETE USER ERROR:', error);
    res.status(500).json({ message: 'Failed to delete user', error: error.message });
  }
};

module.exports = { adminLogin, getAllUsers, deleteUser };