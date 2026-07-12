const express = require("express");
const router = express.Router();
const {
  createPaymentRequest,
  verifyPaymentRequest,
  getPaymentStatus,
  getTenantPaymentRequests
} = require("../controllers/paymentController");

router.post("/request", createPaymentRequest);
router.post("/verify/:requestId", verifyPaymentRequest);
router.get("/status/:userId", getPaymentStatus);
router.get('/tenant-requests/:userId', getTenantPaymentRequests);
module.exports = router;
