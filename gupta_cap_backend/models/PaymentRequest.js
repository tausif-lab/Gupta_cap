const mongoose = require('mongoose');

const paymentRequestSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    userName: { type: String, required: true },
    mobile: { type: String, required: true },
    flat: { type: String, required: true },
    monthlyRent: { type: Number, required: true },
    penaltyAmount: { type: Number, default: 0 },
    totalPaid: { type: Number, required: true },
    dueDate: { type: Date, required: true },
    cycleStart: { type: Date, required: true },
    periodEnd: { type: Date, required: true },
    cycleMonthLabel: { type: String, required: true },

    status: {
      type: String,
      enum: ['Pending Verification', 'Verified', 'Rejected'],
      default: 'Pending Verification',
    },
  },
  { timestamps: true },
);

module.exports = mongoose.model('PaymentRequest', paymentRequestSchema);