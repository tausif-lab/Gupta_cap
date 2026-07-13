const express = require('express');
const router = express.Router();
const { getUserDetails } = require('../controllers/userController');
const { verifyToken } = require('../middleware/auth');

router.get('/:userId', verifyToken, getUserDetails);

module.exports = router;
