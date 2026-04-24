const express = require("express");
const router = express.Router();
const stockController = require("../controllers/stockController");
const { authenticate, checkRole } = require("../middleware/authMiddleware");
const { ROLES } = require("../config/roles");

router.get("/", authenticate, stockController.getAllStocks);
router.put("/:transporter", checkRole(ROLES.ADMIN, ROLES.AGENT_STOCK), stockController.updateStock);

module.exports = router;
