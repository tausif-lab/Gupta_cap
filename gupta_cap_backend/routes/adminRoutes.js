const express = require('express');
const router = express.Router();
const { adminLogin, getAllTenants } = require('../controllers/adminController');

router.post('/login', adminLogin);
router.get('/tenants', getAllTenants);

module.exports = router;