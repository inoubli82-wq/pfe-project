// ==============================================
// EXPORT ROUTES
// ==============================================

const express = require("express");
const router = express.Router();
const exportController = require("../controllers/exportController");
const { checkRole } = require("../middleware/authMiddleware");
const { ROLES } = require("../config/roles");

// All export routes require ADMIN or AGENT_EXPORT role
const exportAccess = checkRole(ROLES.ADMIN, ROLES.AGENT_EXPORT);

// POST /api/exports - Create new export
router.post("/", exportAccess, exportController.createExport);

// GET /api/exports - Get all exports
router.get("/", exportAccess, exportController.getAllExports);

// GET /api/exports/:id - Get single export
router.get("/:id", exportAccess, exportController.getExportById);

// PATCH /api/exports/:id/status - Update export status
router.patch("/:id/status", exportAccess, exportController.updateExportStatus);

// DELETE /api/exports/:id - Delete export
router.delete("/:id", exportAccess, exportController.deleteExport);

module.exports = router;
