const express = require('express');
const router = express.Router();
const exportController = require('../controllers/exportController');

// Routes
router.get('/', exportController.getAllExports);
router.post('/', exportController.createExport);
router.put('/:id', exportController.updateExport);
router.delete('/:id', exportController.deleteExport);

module.exports = router;