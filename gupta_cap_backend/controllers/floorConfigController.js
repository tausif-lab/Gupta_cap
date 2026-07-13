const FloorConfig = require('../models/FloorConfig');

const getFloorConfigs = async (req, res) => {
  try {
    const configs = await FloorConfig.find().sort({ floor: 1 });
    res.json({ floors: configs });
  } catch (error) {
    console.error('GET FLOOR CONFIGS ERROR:', error);
    res.status(500).json({ message: 'Failed to fetch floor configs', error: error.message });
  }
};

const saveFloorConfigs = async (req, res) => {
  try {
    const { floors } = req.body;
    if (!Array.isArray(floors) || floors.length === 0) {
      return res.status(400).json({ message: 'Floors array is required' });
    }

    await FloorConfig.deleteMany({});

    const created = await FloorConfig.insertMany(
      floors.map((f) => ({
        floor: f.floor,
        rooms: f.rooms || [],
      })),
    );

    res.json({ message: 'Floor configs saved successfully', floors: created });
  } catch (error) {
    console.error('SAVE FLOOR CONFIGS ERROR:', error);
    res.status(500).json({ message: 'Failed to save floor configs', error: error.message });
  }
};

module.exports = { getFloorConfigs, saveFloorConfigs };
