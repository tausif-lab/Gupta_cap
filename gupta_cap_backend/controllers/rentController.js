const RentConfig = require("../models/RentConfig");

// @desc   Get rent config for a tenant
// @route  GET /api/admin/rent/:userId
const getRentConfig = async (req, res) => {
  try {
    const config = await RentConfig.findOne({ userId: req.params.userId });
    if (!config) {
      return res
        .status(404)
        .json({ message: "No rent config found for this tenant" });
    }
    res.json(config);
  } catch (error) {
    console.error("GET RENT CONFIG ERROR:", error);
    res
      .status(500)
      .json({ message: "Failed to fetch rent config", error: error.message });
  }
};

// @desc   Create or update rent config for a tenant
// @route  POST /api/admin/rent/:userId
const saveRentConfig = async (req, res) => {
  try {
    const {
      rentStartDate,
      dueDays,
      penaltyStartDay,
      monthlyRent,
      penaltyPerDay,
      penaltyEnabled,
    } = req.body;

    if (!rentStartDate || !monthlyRent) {
      return res
        .status(400)
        .json({ message: "Rent start date and monthly rent are required" });
    }

    const existing = await RentConfig.findOne({ userId: req.params.userId });

    const config = await RentConfig.findOneAndUpdate(
      { userId: req.params.userId },
      {
        userId: req.params.userId,
        rentStartDate,
        dueDays,
        penaltyStartDay,
        monthlyRent,
        penaltyPerDay,
        penaltyEnabled,
        // Only set on first creation — don't reset an active cycle on edits
        currentCycleStart: existing?.currentCycleStart || rentStartDate,
      },
      { upsert: true, new: true },
    );

    res.json({ message: "Rent config saved successfully", config });
  } catch (error) {
    console.error("SAVE RENT CONFIG ERROR:", error);
    res
      .status(500)
      .json({ message: "Failed to save rent config", error: error.message });
  }
};

module.exports = { getRentConfig, saveRentConfig };
