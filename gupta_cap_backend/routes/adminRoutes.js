const express = require('express');
const router = express.Router();
const { adminLogin, getAllTenants } = require('../controllers/adminController');
const { getAllQueries, resolveQuery } = require('../controllers/queryController');
const { verifyToken, adminOnly } = require('../middleware/auth');

router.post('/login', adminLogin);
router.get('/tenants', verifyToken, adminOnly, getAllTenants);
router.get('/queries', verifyToken, adminOnly, getAllQueries);
router.put('/queries/:queryId/resolve', verifyToken, adminOnly, resolveQuery);

module.exports = router;
