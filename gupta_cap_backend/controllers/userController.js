const User = require('../models/User');
const RentConfig = require('../models/RentConfig');

// @desc  Get user info + rent config + calculated due date & days left
// @route GET /api/user/:userId
const getUserDetails = async (req, res) => {
  try {
    const user = await User.findById(req.params.userId, 'name mobile email floor room roomType flat paymentStatus');
    if (!user) return res.status(404).json({ message: 'User not found' });

    const config = await RentConfig.findOne({ userId: req.params.userId });

    let rentInfo = null;
    if (config) {
      const today = new Date();
today.setHours(0, 0, 0, 0);

const cycleStart = new Date(config.currentCycleStart || config.rentStartDate);
cycleStart.setHours(0, 0, 0, 0);

// Prepaid: due date is the start of the billing period (pay before you stay)
const dueDate = new Date(cycleStart);

const daysLeft = Math.ceil((dueDate - today) / (1000 * 60 * 60 * 24));


// Roll forward month by month until we reach the current/upcoming cycle
/*while (dueDate < today) {
  dueDate.setMonth(dueDate.getMonth() + 1);
}
*/

      // Calculate penalty
      let penaltyAmount = 0;
if (config.penaltyEnabled && daysLeft < 0) {
  const overdueDays = Math.abs(daysLeft);
  if (overdueDays > config.penaltyStartDay) {
    penaltyAmount = (overdueDays - config.penaltyStartDay) * config.penaltyPerDay;
  }
}

// Rent period always spans exactly 1 month from cycleStart
const periodEnd = new Date(cycleStart);
periodEnd.setMonth(periodEnd.getMonth() + 1);

// Label like "July 2026" for clarity in the UI
const cycleMonthLabel = cycleStart.toLocaleString('en-US', { month: 'long', year: 'numeric' });

rentInfo = {
  monthlyRent: config.monthlyRent,
  cycleStart,
  periodEnd,
  cycleMonthLabel,
  dueDate,
  daysLeft,
  penaltyEnabled: config.penaltyEnabled,
  penaltyPerDay: config.penaltyPerDay,
  penaltyStartDay: config.penaltyStartDay,
  penaltyAmount,
  totalDue: config.monthlyRent + penaltyAmount,
};
    }
    console.log('SENDING RENT INFO:', rentInfo);
    res.json({ user, rentInfo });
  } catch (error) {
    console.error('GET USER DETAILS ERROR:', error);
    res.status(500).json({ message: 'Failed to fetch user details', error: error.message });
  }
};

module.exports = { getUserDetails };