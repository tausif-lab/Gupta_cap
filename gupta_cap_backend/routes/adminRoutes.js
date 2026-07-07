const express = require('express');
const router = express.Router();
const { adminLogin, getAllTenants } = require('../controllers/adminController');
const { getAllQueries, resolveQuery } = require('../controllers/queryController');

router.post('/login', adminLogin);
router.get('/tenants', getAllTenants);
router.get('/queries', getAllQueries);
router.put('/queries/:queryId/resolve', resolveQuery);

module.exports = router;