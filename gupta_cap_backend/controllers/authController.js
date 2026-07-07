const bcrypt = require('bcryptjs');
const User = require('../models/User');

// @desc    Register new user
// @route   POST /api/register
const registerUser = async (req, res) => {
  try {
    const { name, mobile, email, flat, password } = req.body;

    if (!name || !mobile || !flat || !password) {
      return res.status(400).json({
        message: 'Name, mobile, flat and password are required',
      });
    }

    const existingUser = await User.findOne({ mobile });
    if (existingUser) {
      return res.status(409).json({
        message: 'User already exists with this mobile number',
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({
      name,
      mobile,
      email: email || '',
      flat,
      password: hashedPassword,
    });

    res.status(201).json({
      message: 'Registration successful',
      user: {
        id: user._id,
        name: user.name,
        mobile: user.mobile,
        email: user.email,
        flat: user.flat,
      },
    });
  } catch (error) {
    console.error('REGISTER ERROR:', error);
    if (!res.headersSent) {
      res.status(500).json({
        message: 'Registration failed',
        error: error.message,
      });
    }
  }
};

// @desc    Login user
// @route   POST /api/login
const loginUser = async (req, res) => {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({
        message: 'Please provide mobile/email and password',
      });
    }

    const user = await User.findOne({
      $or: [{ mobile: identifier }, { email: identifier }],
    });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid password' });
    }

    res.json({
      message: 'Login successful',
      user: {
        id: user._id,
        name: user.name,
        mobile: user.mobile,
        email: user.email,
        flat: user.flat,
        paymentStatus: user.paymentStatus,
      },
    });
  } catch (error) {
    console.error('LOGIN ERROR:', error);
    res.status(500).json({
      message: 'Login failed',
      error: error.message,
    });
  }
};

module.exports = { registerUser, loginUser };