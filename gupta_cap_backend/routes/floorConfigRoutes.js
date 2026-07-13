const express = require('express');
const router = express.Router();
const { getFloorConfigs, saveFloorConfigs } = require('../controllers/floorConfigController');
const { verifyToken, adminOnly } = require('../middleware/auth');

router.get('/', getFloorConfigs);
router.post('/', verifyToken, adminOnly, saveFloorConfigs);

module.exports = router;
