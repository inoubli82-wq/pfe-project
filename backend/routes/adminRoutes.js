// ==============================================
// ADMIN ROUTES
// ==============================================

const express = require("express");
const router = express.Router();
const adminController = require("../controllers/adminController");
const { checkRole } = require("../middleware/authMiddleware");
const { ROLES } = require("../config/roles");

// All admin routes require ADMIN role
const adminOnly = checkRole(ROLES.ADMIN);

// GET /api/admin/users - Get all users
router.get("/users", adminOnly, adminController.getAllUsers);

// GET /api/admin/dashboard - Get dashboard stats
router.get("/dashboard", adminOnly, adminController.getDashboardStats);

// POST /api/admin/users - Create new user
router.post("/users", adminOnly, adminController.createUser);

// PATCH /api/admin/users/:id/status - Update user status
router.patch("/users/:id/status", adminOnly, adminController.updateUserStatus);

// PATCH /api/admin/users/:id/role - Update user role
router.patch("/users/:id/role", adminOnly, adminController.updateUserRole);

// DELETE /api/admin/users/:id - Delete user
router.delete("/users/:id", adminOnly, adminController.deleteUser);

module.exports = router;
