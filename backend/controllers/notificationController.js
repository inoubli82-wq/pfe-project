// ==============================================
// NOTIFICATION CONTROLLER
// ==============================================

const { query, getOne, getMany } = require("../config/database");
const { ROLES } = require("../config/roles");

/**
 * Create a notification
 * @param {Object} notificationData - Notification data
 */
const createNotification = async (notificationData) => {
  const {
    type,
    title,
    message,
    referenceType,
    referenceId,
    senderId,
    recipientId,
    actionRequired = false,
  } = notificationData;

  try {
    const result = await query(
      `INSERT INTO notifications (type, title, message, reference_type, reference_id, sender_id, recipient_id, action_required)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [
        type,
        title,
        message,
        referenceType,
        referenceId,
        senderId,
        recipientId,
        actionRequired,
      ],
    );
    return result.rows[0];
  } catch (error) {
    console.error("Error creating notification:", error);
    throw error;
  }
};

/**
 * Send notifications to partenaire and admin for new request
 * @param {string} requestType - 'export' or 'import'
 * @param {Object} requestData - The request data
 * @param {number} senderId - The user who created the request
 */
const notifyForNewRequest = async (requestType, requestData, senderId) => {
  try {
    // Get all partenaires and admins
    const recipients = await getMany(
      `SELECT id, user_type FROM users WHERE user_type IN ($1, $2) AND status = 'active'`,
      [ROLES.PARTENAIRE, ROLES.ADMIN],
    );

    const senderUser = await getOne(
      "SELECT full_name FROM users WHERE id = $1",
      [senderId],
    );
    const senderName = senderUser?.full_name || "Agent";

    const title =
      requestType === "export"
        ? `Nouvelle demande d'export`
        : `Nouvelle demande d'import`;

    const identifier =
      requestType === "export"
        ? requestData.trailer_number
        : requestData.trailer_number;

    for (const recipient of recipients) {
      const actionRequired = recipient.user_type === ROLES.PARTENAIRE;
      const message =
        requestType === "export"
          ? `${senderName} a créé une demande d'export (${identifier}). ${actionRequired ? "Action requise." : ""}`
          : `${senderName} a créé une demande d'import (${identifier}). ${actionRequired ? "Action requise." : ""}`;

      await createNotification({
        type: `${requestType}_request`,
        title,
        message,
        referenceType: requestType,
        referenceId: requestData.id,
        senderId,
        recipientId: recipient.id,
        actionRequired,
      });
    }

    console.log(
      `📧 Notifications envoyées pour ${requestType} #${requestData.id}`,
    );
  } catch (error) {
    console.error("Error sending notifications:", error);
  }
};

/**
 * Send notifications after partenaire decision
 * @param {string} requestType - 'export' or 'import'
 * @param {number} requestId - Request ID
 * @param {string} decision - 'approved' or 'rejected'
 * @param {number} partenaireId - Partenaire who made the decision
 * @param {string} reason - Rejection reason (optional)
 */
const notifyForDecision = async (
  requestType,
  requestId,
  decision,
  partenaireId,
  reason = null,
) => {
  try {
    // Get the original request creator
    const tableName = requestType === "export" ? "exports" : "imports";
    const request = await getOne(`SELECT * FROM ${tableName} WHERE id = $1`, [
      requestId,
    ]);

    if (!request) return;

    const partenaire = await getOne(
      "SELECT full_name FROM users WHERE id = $1",
      [partenaireId],
    );
    const partenaireName = partenaire?.full_name || "Partenaire";

    // Get all admins for notification
    const admins = await getMany(
      `SELECT id FROM users WHERE user_type = $1 AND status = 'active'`,
      [ROLES.ADMIN],
    );

    const title =
      decision === "approved"
        ? `Demande ${requestType === "export" ? "d'export" : "d'import"} approuvée`
        : `Demande ${requestType === "export" ? "d'export" : "d'import"} refusée`;

    const message =
      decision === "approved"
        ? `Votre demande ${requestType === "export" ? "d'export" : "d'import"} (${request.trailer_number}) a été approuvée par ${partenaireName}.`
        : `Votre demande ${requestType === "export" ? "d'export" : "d'import"} (${request.trailer_number}) a été refusée par ${partenaireName}. ${reason ? `Raison: ${reason}` : ""}`;

    // Notify the creator
    if (request.created_by) {
      await createNotification({
        type: decision === "approved" ? "approval" : "rejection",
        title,
        message,
        referenceType: requestType,
        referenceId: requestId,
        senderId: partenaireId,
        recipientId: request.created_by,
        actionRequired: false,
      });
    }

    // Notify admins
    const adminMessage = `${partenaireName} a ${decision === "approved" ? "approuvé" : "refusé"} la demande ${requestType === "export" ? "d'export" : "d'import"} (${request.trailer_number}).`;

    for (const admin of admins) {
      await createNotification({
        type: "info",
        title: `Mise à jour: ${title}`,
        message: adminMessage,
        referenceType: requestType,
        referenceId: requestId,
        senderId: partenaireId,
        recipientId: admin.id,
        actionRequired: false,
      });
    }

    console.log(
      `📧 Notifications de décision envoyées pour ${requestType} #${requestId}`,
    );
  } catch (error) {
    console.error("Error sending decision notifications:", error);
  }
};

/**
 * Get all notifications for a user
 * GET /api/notifications
 */
const getNotifications = async (req, res) => {
  try {
    const notifications = await getMany(
      `SELECT n.*, u.full_name as sender_name
       FROM notifications n
       LEFT JOIN users u ON n.sender_id = u.id
       WHERE n.recipient_id = $1
       ORDER BY n.created_at DESC`,
      [req.user.id],
    );

    const unreadCount = notifications.filter((n) => !n.is_read).length;

    res.json({
      success: true,
      count: notifications.length,
      unreadCount,
      notifications,
    });
  } catch (error) {
    console.error("Error fetching notifications:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Get unread notification count
 * GET /api/notifications/unread-count
 */
const getUnreadCount = async (req, res) => {
  try {
    const result = await getOne(
      `SELECT COUNT(*) FROM notifications WHERE recipient_id = $1 AND is_read = FALSE`,
      [req.user.id],
    );

    res.json({
      success: true,
      unreadCount: parseInt(result.count),
    });
  } catch (error) {
    console.error("Error fetching unread count:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Mark notification as read
 * PATCH /api/notifications/:id/read
 */
const markAsRead = async (req, res) => {
  try {
    const result = await query(
      `UPDATE notifications SET is_read = TRUE, read_at = CURRENT_TIMESTAMP 
       WHERE id = $1 AND recipient_id = $2 
       RETURNING *`,
      [req.params.id, req.user.id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Notification non trouvée",
      });
    }

    res.json({
      success: true,
      message: "Notification marquée comme lue",
      notification: result.rows[0],
    });
  } catch (error) {
    console.error("Error marking notification as read:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Mark all notifications as read
 * PATCH /api/notifications/read-all
 */
const markAllAsRead = async (req, res) => {
  try {
    await query(
      `UPDATE notifications SET is_read = TRUE, read_at = CURRENT_TIMESTAMP 
       WHERE recipient_id = $1 AND is_read = FALSE`,
      [req.user.id],
    );

    res.json({
      success: true,
      message: "Toutes les notifications marquées comme lues",
    });
  } catch (error) {
    console.error("Error marking all as read:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Get pending requests for partenaire
 * GET /api/notifications/pending-requests
 */
const getPendingRequests = async (req, res) => {
  try {
    // Get pending exports
    const pendingExports = await getMany(
      `SELECT e.*, u.full_name as created_by_name, 'export' as type
       FROM exports e
       LEFT JOIN users u ON e.created_by = u.id
       WHERE e.approval_status = 'pending'
       ORDER BY e.created_at DESC`,
    );

    // Get pending imports
    const pendingImports = await getMany(
      `SELECT i.*, u.full_name as created_by_name, 'import' as type
       FROM imports i
       LEFT JOIN users u ON i.created_by = u.id
       WHERE i.approval_status = 'pending'
       ORDER BY i.created_at DESC`,
    );

    res.json({
      success: true,
      pendingExports,
      pendingImports,
      totalPending: pendingExports.length + pendingImports.length,
    });
  } catch (error) {
    console.error("Error fetching pending requests:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Approve or reject a request (Partenaire only)
 * POST /api/notifications/decision
 */
const handleDecision = async (req, res) => {
  const { requestType, requestId, decision, reason } = req.body;

  try {
    if (!["export", "import"].includes(requestType)) {
      return res.status(400).json({
        success: false,
        message: "Type de demande invalide",
      });
    }

    if (!["approved", "rejected"].includes(decision)) {
      return res.status(400).json({
        success: false,
        message: "Décision invalide",
      });
    }

    const tableName = requestType === "export" ? "exports" : "imports";

    // Update the request
    const result = await query(
      `UPDATE ${tableName} 
       SET approval_status = $1, approved_by = $2, approved_at = CURRENT_TIMESTAMP, rejection_reason = $3
       WHERE id = $4
       RETURNING *`,
      [
        decision,
        req.user.id,
        decision === "rejected" ? reason : null,
        requestId,
      ],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Demande non trouvée",
      });
    }

    // Update the notification action
    await query(
      `UPDATE notifications 
       SET action_taken = $1, action_required = FALSE
       WHERE reference_type = $2 AND reference_id = $3 AND recipient_id = $4`,
      [decision, requestType, requestId, req.user.id],
    );

    // Send notifications about the decision
    await notifyForDecision(
      requestType,
      requestId,
      decision,
      req.user.id,
      reason,
    );

    console.log(
      `✅ ${requestType} #${requestId} ${decision} par ${req.user.email}`,
    );

    res.json({
      success: true,
      message:
        decision === "approved" ? "Demande approuvée" : "Demande refusée",
      request: result.rows[0],
    });
  } catch (error) {
    console.error("Error handling decision:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Delete a notification
 * DELETE /api/notifications/:id
 */
const deleteNotification = async (req, res) => {
  try {
    const result = await query(
      `DELETE FROM notifications WHERE id = $1 AND recipient_id = $2 RETURNING id`,
      [req.params.id, req.user.id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Notification non trouvée",
      });
    }

    res.json({
      success: true,
      message: "Notification supprimée",
    });
  } catch (error) {
    console.error("Error deleting notification:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

module.exports = {
  createNotification,
  notifyForNewRequest,
  notifyForDecision,
  getNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  getPendingRequests,
  handleDecision,
  deleteNotification,
};
