const express = require("express");
const cors = require("cors");
const cron = require("node-cron");
require("dotenv").config();

const { connectDB } = require("./config/database");
const authRoutes = require("./routes/authRoutes");
const adminRoutes = require("./routes/adminRoutes");
const rentRoutes = require("./routes/rentRoutes");
const userRoutes = require("./routes/userRoutes");
const queryRoutes = require("./routes/queryRoutes");
const paymentRoutes = require('./routes/paymentRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const floorConfigRoutes = require('./routes/floorConfigRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get("/api/test", (req, res) => {
  res.json({ message: "Backend server is running smoothly!" });
});

// Routes
app.use("/api", authRoutes);
app.use("/api/admin", adminRoutes);
app.use("/api/admin/rent", rentRoutes);
app.use('/api/user', userRoutes);
app.use("/api", queryRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/floor-configs', floorConfigRoutes);

// ──────────────────────────────────────────────
// Scheduled rent reminder notifications
// ──────────────────────────────────────────────
const RentConfig = require("./models/RentConfig");
const User = require("./models/User");
const Notification = require("./models/Notification");

const generateRentReminders = async () => {
  try {
    const configs = await RentConfig.find({});
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    for (const config of configs) {
      const cycleStart = new Date(config.currentCycleStart || config.rentStartDate);
      cycleStart.setHours(0, 0, 0, 0);
      const dueDate = new Date(cycleStart);
      const daysUntilDue = Math.ceil((dueDate - today) / (1000 * 60 * 60 * 24));

      if (daysUntilDue === 2) {
        const exists = await Notification.findOne({
          userId: config.userId,
          type: 'rent_reminder',
          createdAt: { $gte: new Date(today.getTime() - 24 * 60 * 60 * 1000) },
        });
        if (!exists) {
          await Notification.create({
            userId: config.userId,
            title: 'Rent Due in 2 Days',
            message: `Your rent of ₹${config.monthlyRent} is due in 2 days. Please pay on time to avoid penalties.`,
            type: 'rent_reminder',
          });
        }
      }

      if (daysUntilDue === 0) {
        const exists = await Notification.findOne({
          userId: config.userId,
          type: 'payment_reminder',
          createdAt: { $gte: new Date(today.getTime() - 24 * 60 * 60 * 1000) },
        });
        if (!exists) {
          await Notification.create({
            userId: config.userId,
            title: 'Rent Due Today',
            message: `Your rent of ₹${config.monthlyRent} is due today. Please make the payment at the earliest.`,
            type: 'payment_reminder',
          });
        }
      }
    }
    console.log('Rent reminders checked/generated at', new Date().toISOString());
  } catch (err) {
    console.error('RENT REMINDER CRON ERROR:', err);
  }
};

// Run daily at 8:00 AM
cron.schedule('0 8 * * *', generateRentReminders);

// Also run once on startup (with a short delay)
setTimeout(generateRentReminders, 10000);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: `Route ${req.url} not found` });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error("UNHANDLED ERROR:", err);
  res
    .status(500)
    .json({ message: "Internal server error", error: err.message });
});

// Start server
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  await connectDB();
  app.listen(PORT, () => {
    console.log(`Server is listening on port ${PORT}`);
  });
};

startServer();
