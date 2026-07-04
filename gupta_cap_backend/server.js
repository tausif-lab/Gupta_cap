const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const { connectDB } = require('./config/database');
const User = require('./models/User');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/api/test', (req, res) => {
  res.json({ message: 'Backend server is running smoothly!' });
});

app.post('/api/register', async (req, res) => {
  try {
    const { name, mobile, email, flat, password } = req.body;

    if (!name || !mobile || !flat || !password) {
      return res.status(400).json({ message: 'Name, mobile, flat and password are required' });
    }

    const existingUser = await User.findOne({ mobile });
    if (existingUser) {
      return res.status(409).json({ message: 'User already exists with this mobile number' });
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
    console.error(error);
    res.status(500).json({ message: 'Registration failed', error: error.message });
  }
});

app.post('/api/login', async (req, res) => {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({ message: 'Please provide mobile/email and password' });
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
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Login failed', error: error.message });
  }
});

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`Server is listening on port ${PORT}`);
  });
};

startServer();