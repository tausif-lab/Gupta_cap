const express = require("express");
const router = express.Router();
const {
  createPaymentRequest,
  verifyPaymentRequest,
  getPaymentStatus,
  getTenantPaymentRequests
} = require("../controllers/paymentController");
const { verifyToken, adminOnly } = require("../middleware/auth");

router.post("/request", verifyToken, createPaymentRequest);
router.post("/verify/:requestId", verifyToken, adminOnly, verifyPaymentRequest);
router.get("/status/:userId", verifyToken, getPaymentStatus);
router.get('/tenant-requests/:userId', verifyToken, getTenantPaymentRequests);
router.get('/history/:userId', verifyToken, getTenantPaymentRequests);

module.exports = router;
