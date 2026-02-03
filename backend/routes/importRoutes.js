// ==============================================
// IMPORT ROUTES
// ==============================================

const express = require("express");
const router = express.Router();
const importController = require("../controllers/importController");
const { checkRole } = require("../middleware/authMiddleware");
const { ROLES } = require("../config/roles");

// All import routes require ADMIN or AGENT_IMPORT role
const importAccess = checkRole(ROLES.ADMIN, ROLES.AGENT_IMPORT);

// POST /api/imports - Create new import
router.post("/", importAccess, importController.createImport);

// GET /api/imports - Get all imports
router.get("/", importAccess, importController.getAllImports);

// GET /api/imports/:id - Get single import
router.get("/:id", importAccess, importController.getImportById);

// PATCH /api/imports/:id/status - Update import status
router.patch("/:id/status", importAccess, importController.updateImportStatus);

// DELETE /api/imports/:id - Delete import
router.delete("/:id", importAccess, importController.deleteImport);

module.exports = router;
