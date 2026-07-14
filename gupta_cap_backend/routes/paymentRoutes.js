const express = require("express");
const router = express.Router();
const {
  createPaymentRequest,
  verifyPaymentRequest,
  getPaymentStatus,
  getUserPaymentRequests
} = require("../controllers/paymentController");
const { verifyToken, adminOnly } = require("../middleware/auth");

router.post("/request", verifyToken, createPaymentRequest);
router.post("/verify/:requestId", verifyToken, adminOnly, verifyPaymentRequest);
router.get("/status/:userId", verifyToken, getPaymentStatus);
router.get('/user-requests/:userId', verifyToken, getUserPaymentRequests);
router.get('/history/:userId', verifyToken, getUserPaymentRequests);

module.exports = router;
