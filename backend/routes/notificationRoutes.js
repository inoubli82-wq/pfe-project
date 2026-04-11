// ==============================================
// NOTIFICATION ROUTES
// ==============================================

const express = require("express");
const router = express.Router();
const notificationController = require("../controllers/notificationController");
const { checkRole, authenticate } = require("../middleware/authMiddleware");
const { ROLES } = require("../config/roles");

// All notification routes require authentication
router.use(authenticate);

// GET /api/notifications - Get all notifications for current user
router.get("/", notificationController.getNotifications);

// GET /api/notifications/unread-count - Get unread count
router.get("/unread-count", notificationController.getUnreadCount);

// GET /api/notifications/pending-requests - Get pending requests
router.get(
  "/pending-requests",
  checkRole(ROLES.PARTENAIRE, ROLES.ADMIN, ROLES.AGENT_IMPORT),
  notificationController.getPendingRequests,
);

// POST /api/notifications/decision - Approve or reject request
router.post(
  "/decision",
  checkRole(ROLES.PARTENAIRE, ROLES.AGENT_IMPORT, ROLES.ADMIN),
  notificationController.handleDecision,
);

// PATCH /api/notifications/read-all - Mark all as read
router.patch("/read-all", notificationController.markAllAsRead);

// PATCH /api/notifications/:id/read - Mark single notification as read
router.patch("/:id/read", notificationController.markAsRead);

// DELETE /api/notifications/:id - Delete notification
router.delete("/:id", notificationController.deleteNotification);

module.exports = router;
