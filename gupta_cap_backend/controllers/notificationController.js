const Notification = require('../models/Notification');
const RentConfig = require('../models/RentConfig');

const getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.params.userId })
      .sort({ createdAt: -1 });
    res.json({ notifications });
  } catch (error) {
    console.error('GET NOTIFICATIONS ERROR:', error);
    res.status(500).json({ message: 'Failed to fetch notifications', error: error.message });
  }
};

const getUnreadCount = async (req, res) => {
  try {
    const count = await Notification.countDocuments({ userId: req.params.userId, isRead: false });
    res.json({ unreadCount: count });
  } catch (error) {
    console.error('UNREAD COUNT ERROR:', error);
    res.status(500).json({ message: 'Failed to get unread count', error: error.message });
  }
};

const markAsRead = async (req, res) => {
  try {
    const notification = await Notification.findByIdAndUpdate(
      req.params.id,
      { isRead: true },
      { new: true },
    );
    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }
    res.json({ message: 'Marked as read', notification });
  } catch (error) {
    console.error('MARK READ ERROR:', error);
    res.status(500).json({ message: 'Failed to mark as read', error: error.message });
  }
};

const markAllAsRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { userId: req.params.userId, isRead: false },
      { isRead: true },
    );
    res.json({ message: 'All notifications marked as read' });
  } catch (error) {
    console.error('MARK ALL READ ERROR:', error);
    res.status(500).json({ message: 'Failed to mark all as read', error: error.message });
  }
};

const createPaymentReminder = async (req, res) => {
  try {
    const { userId } = req.body;
    if (!userId) {
      return res.status(400).json({ message: 'userId is required' });
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const existing = await Notification.findOne({
      userId,
      type: 'payment_reminder',
      createdAt: { $gte: today, $lt: tomorrow },
    });

    if (existing) {
      return res.json({ message: 'Reminder already sent today', alreadyExists: true });
    }

    const config = await RentConfig.findOne({ userId });
    const rentAmount = config?.monthlyRent || 0;

    const notification = await Notification.create({
      userId,
      title: 'Payment Reminder',
      message: `Please pay your rent of ₹${rentAmount}. Scan the QR code and submit the payment request.`,
      type: 'payment_reminder',
    });

    res.status(201).json({ message: 'Payment reminder sent', notification });
  } catch (error) {
    console.error('CREATE PAYMENT REMINDER ERROR:', error);
    res.status(500).json({ message: 'Failed to create reminder', error: error.message });
  }
};

module.exports = { getNotifications, getUnreadCount, markAsRead, markAllAsRead, createPaymentReminder };
