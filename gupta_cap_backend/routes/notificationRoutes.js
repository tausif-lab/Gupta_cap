const express = require('express');
const router = express.Router();
const {
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  createPaymentReminder,
} = require('../controllers/notificationController');
const { verifyToken } = require('../middleware/auth');

router.get('/:userId', verifyToken, getNotifications);
router.get('/:userId/unread-count', verifyToken, getUnreadCount);
router.put('/:id/read', verifyToken, markAsRead);
router.put('/read-all/:userId', verifyToken, markAllAsRead);
router.post('/remind-payment', verifyToken, createPaymentReminder);

module.exports = router;
