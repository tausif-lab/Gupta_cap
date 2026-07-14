const express = require('express');
const router = express.Router();
const { adminLogin, getAllUsers, deleteUser } = require('../controllers/adminController');
const { getAllQueries, resolveQuery } = require('../controllers/queryController');
const { verifyToken, adminOnly } = require('../middleware/auth');

router.post('/login', adminLogin);
router.get('/users', verifyToken, adminOnly, getAllUsers);
router.get('/queries', verifyToken, adminOnly, getAllQueries);
router.put('/queries/:queryId/resolve', verifyToken, adminOnly, resolveQuery);
router.delete('/users/:userId', deleteUser);

module.exports = router;
