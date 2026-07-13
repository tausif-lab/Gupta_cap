const bcrypt = require('bcryptjs');
const User = require('../models/User');
const { generateToken } = require('../middleware/auth');

const registerUser = async (req, res) => {
  try {
    const { name, mobile, email, floor, room, roomType, password } = req.body;

    if (!name || !mobile || !floor || !room || !password) {
      return res.status(400).json({
        message: 'Name, mobile, floor, room and password are required',
      });
    }

    const existingUser = await User.findOne({ mobile });
    if (existingUser) {
      return res.status(409).json({
        message: 'User already exists with this mobile number',
      });
    }

    const flatLabel = `${floor} - Room ${room}${roomType ? ` (${roomType})` : ''}`;

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({
      name,
      mobile,
      email: email || '',
      floor,
      room,
      roomType: roomType || 'Residential',
      flat: flatLabel,
      password: hashedPassword,
    });

    const token = generateToken({ id: user._id, role: 'user' });

    res.status(201).json({
      message: 'Registration successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        mobile: user.mobile,
        email: user.email,
        floor: user.floor,
        room: user.room,
        roomType: user.roomType,
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

    const token = generateToken({ id: user._id, role: 'user' });

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        mobile: user.mobile,
        email: user.email,
        floor: user.floor,
        room: user.room,
        roomType: user.roomType,
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