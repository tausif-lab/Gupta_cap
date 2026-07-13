const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    mobile: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    email: {
      type: String,
      trim: true,
      lowercase: true,
      default: '',
    },
    floor: {
      type: String,
      trim: true,
      default: '',
    },
    room: {
      type: String,
      trim: true,
      default: '',
    },
    roomType: {
      type: String,
      enum: ['Residential', 'Commercial'],
      default: 'Residential',
    },
    flat: {
      type: String,
      trim: true,
      default: '',
    },
    password: {
      type: String,
      required: true,
    },
    paymentStatus: {
    type: String,
    enum: ['Paid', 'Pending', 'Overdue'],
    default: 'Pending',
    },
  },
  { timestamps: true },
);

userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
