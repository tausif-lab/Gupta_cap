const express = require('express');
const router = express.Router();
const { submitQuery, getUserQueries } = require('../controllers/queryController');
const { verifyToken } = require('../middleware/auth');

router.post('/query', verifyToken, submitQuery);
router.get('/query/user/:userId', verifyToken, getUserQueries);

module.exports = router;
