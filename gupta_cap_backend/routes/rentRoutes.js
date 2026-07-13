const express = require('express');
const router = express.Router();
const { getRentConfig, saveRentConfig } = require('../controllers/rentController');
const { verifyToken, adminOnly } = require('../middleware/auth');

router.get('/:userId', verifyToken, adminOnly, getRentConfig);
router.post('/:userId', verifyToken, adminOnly, saveRentConfig);

module.exports = router;
