// ==============================================
// AUTH ROUTES
// ==============================================

const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");

// POST /api/auth/register - Register new user
router.post("/register", authController.register);

// POST /api/auth/login - Login user
router.post("/login", authController.login);

// GET /api/auth/profile - Get user profile
router.get("/profile", authController.getProfile);

// POST /api/auth/forgot-password - Request password reset
router.post("/forgot-password", authController.forgotPassword);

module.exports = router;
