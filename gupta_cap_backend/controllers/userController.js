const User = require('../models/User');
const RentConfig = require('../models/RentConfig');

// @desc  Get user info + rent config + calculated due date & days left
// @route GET /api/user/:userId
const getUserDetails = async (req, res) => {
  try {
    const user = await User.findById(req.params.userId, 'name mobile email flat paymentStatus');
    if (!user) return res.status(404).json({ message: 'User not found' });

    const config = await RentConfig.findOne({ userId: req.params.userId });

    let rentInfo = null;
    if (config) {
      const today = new Date();
      const startDate = new Date(config.rentStartDate);

      // Calculate next due date (same day of month as startDate, current or next month)
      const dueDate = new Date(today.getFullYear(), today.getMonth(), startDate.getDate() + config.dueDays - 1);
      if (dueDate < today) {
        dueDate.setMonth(dueDate.getMonth() + 1);
      }

      const daysLeft = Math.ceil((dueDate - today) / (1000 * 60 * 60 * 24));

      // Calculate penalty
      let penaltyAmount = 0;
      if (config.penaltyEnabled && daysLeft < 0) {
        const overdueDays = Math.abs(daysLeft) - config.penaltyStartDay;
        if (overdueDays > 0) {
          penaltyAmount = overdueDays * config.penaltyPerDay;
        }
      }

      rentInfo = {
        monthlyRent: config.monthlyRent,
        rentStartDate: config.rentStartDate,
        dueDays: config.dueDays,
        dueDate,
        daysLeft,
        penaltyEnabled: config.penaltyEnabled,
        penaltyPerDay: config.penaltyPerDay,
        penaltyStartDay: config.penaltyStartDay,
        penaltyAmount,
        totalDue: config.monthlyRent + penaltyAmount,
      };
    }

    res.json({ user, rentInfo });
  } catch (error) {
    console.error('GET USER DETAILS ERROR:', error);
    res.status(500).json({ message: 'Failed to fetch user details', error: error.message });
  }
};

module.exports = { getUserDetails };