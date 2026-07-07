const mongoose = require('mongoose');

const querySchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    userName: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      default: '',
    },
    subject: {
      type: String,
      required: true,
      trim: true,
    },
    message: {
      type: String,
      required: true,
      trim: true,
    },
    status: {
      type: String,
      enum: ['pending', 'resolved'],
      default: 'pending',
    },
    adminReply: {
      type: String,
      default: null,
    },
    resolvedAt: {
      type: Date,
      default: null,
    },
  },
  { timestamps: true },
);

module.exports = mongoose.model('Query', querySchema);
