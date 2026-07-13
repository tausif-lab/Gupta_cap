const mongoose = require('mongoose');

const roomSchema = new mongoose.Schema({
  number: { type: String, required: true },
  type: { type: String, enum: ['Residential', 'Commercial'], required: true },
}, { _id: false });

const floorConfigSchema = new mongoose.Schema({
  floor: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  rooms: [roomSchema],
}, { timestamps: true });

module.exports = mongoose.model('FloorConfig', floorConfigSchema);
