// ==============================================
// PARTNER EXPORT ROUTES
// ==============================================

const express = require("express");
const router = express.Router();
const { checkRole } = require("../middleware/authMiddleware");
const { ROLES } = require("../config/roles");
const {
  createExportData,
  getAllExportData,
  getExportDataById,
  updateExportData,
  deleteExportData,
  approveExportData,
  rejectExportData,
} = require("../controllers/partnerExportController");

// Partner export routes - for partner users to create/manage their own exports
const partnerAccess = checkRole(
  ROLES.ADMIN,
  ROLES.PARTENAIRE,
  ROLES.AGENT_EXPORT
);

// POST /api/export-data - Create new partner export
router.post("/", partnerAccess, createExportData);

// GET /api/export-data - Get all partner exports
router.get("/", partnerAccess, getAllExportData);

// GET /api/export-data/:id - Get single partner export
router.get("/:id", partnerAccess, getExportDataById);

// PUT /api/export-data/:id - Update partner export
router.put("/:id", partnerAccess, updateExportData);

// DELETE /api/export-data/:id - Delete partner export
router.delete("/:id", partnerAccess, deleteExportData);

// PUT /api/export-data/:id/approve - Approve partner export (agent import role)
router.put("/:id/approve", checkRole(ROLES.AGENT_IMPORT, ROLES.ADMIN), approveExportData);

// PUT /api/export-data/:id/reject - Reject partner export (agent import role)
router.put("/:id/reject", checkRole(ROLES.AGENT_IMPORT, ROLES.ADMIN), rejectExportData);

module.exports = router;
