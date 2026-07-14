const PaymentRequest = require("../models/PaymentRequest");
const User = require("../models/User");
const RentConfig = require("../models/RentConfig");
// @desc  Create a payment verification request
// @route POST /api/payment/request
const createPaymentRequest = async (req, res) => {
  try {
    const { userId, userName, mobile, flat, monthlyRent, penaltyAmount, totalPaid, dueDate, cycleStart, periodEnd, cycleMonthLabel } = req.body;

if (!userId || !totalPaid || !dueDate || !cycleStart || !periodEnd || !cycleMonthLabel) {
  return res.status(400).json({ message: 'Missing required payment details' });
}

const request = await PaymentRequest.create({
  userId,
  userName,
  mobile,
  flat,
  monthlyRent,
  penaltyAmount,
  totalPaid,
  dueDate,
  cycleStart,
  periodEnd,
  cycleMonthLabel,
});
    res
      .status(201)
      .json({ message: "Payment request submitted for verification", request });
  } catch (error) {
    console.error("CREATE PAYMENT REQUEST ERROR:", error);
    res
      .status(500)
      .json({
        message: "Failed to submit payment request",
        error: error.message,
      });
  }
};

const verifyPaymentRequest = async (req, res) => {
  try {
    const request = await PaymentRequest.findById(req.params.requestId);
    if (!request)
      return res.status(404).json({ message: "Payment request not found" });

    if (request.status === "Verified") {
      return res.status(400).json({ message: "Already verified" });
    }

    request.status = "Verified";
    await request.save({ validateModifiedOnly: true });

    // Advance the rent cycle to the next month
    const config = await RentConfig.findOne({ userId: request.userId });
    if (config) {
      // Fallback to rentStartDate if currentCycleStart was never set (old records)
      const baseCycle = new Date(
        config.currentCycleStart || config.rentStartDate,
      );

      // Prepaid: next cycle starts 1 month after the current cycle start
      const nextCycle = new Date(baseCycle);
      nextCycle.setMonth(nextCycle.getMonth() + 1);

      config.currentCycleStart = nextCycle;
      await config.save({ validateModifiedOnly: true });
    }

    res.json({ message: "Payment verified, cycle advanced", request });
  } catch (error) {
    console.error("VERIFY PAYMENT ERROR:", error);
    res
      .status(500)
      .json({ message: "Failed to verify payment", error: error.message });
  }
};
const getPaymentStatus = async (req, res) => {
  try {
    const latestRequest = await PaymentRequest.findOne({
      userId: req.params.userId,
    }).sort({ createdAt: -1 });

    if (!latestRequest) {
      return res.json({ hasPendingRequest: false });
    }

    res.json({
      hasPendingRequest: latestRequest.status === "Pending Verification",
      status: latestRequest.status,
      cycleMonthLabel: latestRequest.cycleMonthLabel,
      totalPaid: latestRequest.totalPaid,
    });
  } catch (error) {
    console.error("GET PAYMENT STATUS ERROR:", error);
    res
      .status(500)
      .json({
        message: "Failed to fetch payment status",
        error: error.message,
      });
  }
};

const getUserPaymentRequests = async (req, res) => {
  try {
    const requests = await PaymentRequest.find({
      userId: req.params.userId,
    }).sort({ createdAt: -1 });
    res.json({ requests });
  } catch (error) {
    console.error("GET USER PAYMENT REQUESTS ERROR:", error);
    res
      .status(500)
      .json({ message: "Failed to fetch requests", error: error.message });
  }
};
module.exports = {
  createPaymentRequest,
  verifyPaymentRequest,
  getPaymentStatus,
  getUserPaymentRequests,
};
