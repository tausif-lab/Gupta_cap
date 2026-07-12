const Query = require('../models/Query');
const User = require('../models/User');

const submitQuery = async (req, res) => {
  try {
    const { userId, subject, message } = req.body;

    if (!userId || !subject || !message) {
      return res.status(400).json({ message: 'userId, subject, and message are required' });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const query = await Query.create({
      userId: user._id,
      userName: user.name,
      email: user.email || '',
      subject: subject.trim(),
      message: message.trim(),
    });

    res.status(201).json({ message: 'Query submitted successfully', query });
  } catch (error) {
    console.error('SUBMIT QUERY ERROR:', error);
    res.status(500).json({ message: 'Failed to submit query', error: error.message });
  }
};

const getUserQueries = async (req, res) => {
  try {
    const { userId } = req.params;

    const queries = await Query.find({ userId }).sort({ createdAt: -1 });

    res.json({ queries });
  } catch (error) {
    console.error('GET USER QUERIES ERROR:', error);
    res.status(500).json({ message: 'Failed to fetch queries', error: error.message });
  }
};

const getAllQueries = async (req, res) => {
  try {
    const { status } = req.query;
    const filter = status && ['pending', 'resolved'].includes(status) ? { status } : {};

    const queries = await Query.find(filter).sort({ createdAt: -1 });

    res.json({ totalQueries: queries.length, queries });
  } catch (error) {
    console.error('GET ALL QUERIES ERROR:', error);
    res.status(500).json({ message: 'Failed to fetch queries', error: error.message });
  }
};

const resolveQuery = async (req, res) => {
  try {
    const { queryId } = req.params;
    const { adminReply } = req.body;

    if (!adminReply || !adminReply.trim()) {
      return res.status(400).json({ message: 'Admin reply is required' });
    }

    const query = await Query.findByIdAndUpdate(
      queryId,
      {
        status: 'resolved',
        adminReply: adminReply.trim(),
        resolvedAt: new Date(),
      },
      { new: true },
    );

    if (!query) {
      return res.status(404).json({ message: 'Query not found' });
    }

    res.json({ message: 'Query resolved successfully', query });
  } catch (error) {
    console.error('RESOLVE QUERY ERROR:', error);
    res.status(500).json({ message: 'Failed to resolve query', error: error.message });
  }
};

module.exports = { submitQuery, getUserQueries, getAllQueries, resolveQuery };
