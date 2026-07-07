const express = require('express');
const router = express.Router();
const { getRentConfig, saveRentConfig } = require('../controllers/rentController');

router.get('/:userId', getRentConfig);
router.post('/:userId', saveRentConfig);

module.exports = router;