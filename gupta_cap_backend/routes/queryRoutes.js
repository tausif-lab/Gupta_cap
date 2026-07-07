const express = require('express');
const router = express.Router();
const { submitQuery, getUserQueries } = require('../controllers/queryController');

router.post('/query', submitQuery);
router.get('/query/user/:userId', getUserQueries);

module.exports = router;
