const mongoose = require('mongoose');

const rentConfigSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    rentStartDate: {
      type: Date,
      required: true,
    },
    penaltyStartDay: {
      type: Number,
      required: true,
      default: 5,
    },
    monthlyRent: {
      type: Number,
      required: true,
    },
    penaltyPerDay: {
      type: Number,
      required: true,
      default: 0,
    },
    penaltyEnabled: {
      type: Boolean,
      default: true,
    },
    rentStartDate: {
      type: Date,
      required: true,
    },
    currentCycleStart: {
      type: Date,
      required: true,
    },
  },
  { timestamps: true },
);

module.exports = mongoose.model('RentConfig', rentConfigSchema);