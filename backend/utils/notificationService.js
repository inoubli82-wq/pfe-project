// ==============================================
// NOTIFICATION SERVICE
// ==============================================

const { query, getOne, getMany } = require("../config/database");
const { ROLES } = require("../config/roles");

/**
 * Create a notification
 * @param {Object} notificationData
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
      [type, title, message, referenceType, referenceId, senderId, recipientId, actionRequired]
    );
    return result.rows[0];
  } catch (error) {
    console.error("Error creating notification:", error);
    throw error;
  }
};

/**
 * WORKFLOW 1: Agent Export Created
 * Agent Creates Export → Partenaire gets actionRequired notification + Admin gets info notification
 */
const notifyAgentExportCreated = async (exportData, agentId) => {
  try {
    // Get sender name
    const agent = await getOne("SELECT full_name FROM users WHERE id = $1", [agentId]);
    const agentName = agent?.full_name || "Agent";

    // Get all partenaires and admins
    const partenaires = await getMany(
      `SELECT id FROM users WHERE user_type = $1 AND status = 'active'`,
      [ROLES.PARTENAIRE]
    );
    const admins = await getMany(
      `SELECT id FROM users WHERE user_type = $1 AND status = 'active'`,
      [ROLES.ADMIN]
    );

    const title = "Nouvelle demande d'export";
    const trailerNumber = exportData.trailer_number;

    // Notify partenaires - they need to approve/reject
    for (const partenaire of partenaires) {
      await createNotification({
        type: "export_request",
        title,
        message: `${agentName} a créé une demande d'export (${trailerNumber}). Action requise.`,
        referenceType: "export",
        referenceId: exportData.id,
        senderId: agentId,
        recipientId: partenaire.id,
        actionRequired: true,
      });
    }

    // Notify admins - for information only
    for (const admin of admins) {
      await createNotification({
        type: "export_request",
        title,
        message: `${agentName} a créé une demande d'export (${trailerNumber}).`,
        referenceType: "export",
        referenceId: exportData.id,
        senderId: agentId,
        recipientId: admin.id,
        actionRequired: false,
      });
    }

    console.log(`📧 Notifications envoyées pour agent export #${exportData.id}`);
  } catch (error) {
    console.error("Error notifying agent export creation:", error);
  }
};

/**
 * WORKFLOW 2: Partenaire Export Created
 * Partenaire Creates Export → Agent Import gets actionRequired notification + Admin gets info notification
 */
const notifyPartnerExportCreated = async (exportData, partenaiId) => {
  try {
    // Get sender name
    const partenaire = await getOne("SELECT full_name FROM users WHERE id = $1", [partenaiId]);
    const partenaireName = partenaire?.full_name || "Partenaire";

    // Get all agent imports and admins
    const agentImports = await getMany(
      `SELECT id FROM users WHERE user_type = $1 AND status = 'active'`,
      [ROLES.AGENT_IMPORT]
    );
    const admins = await getMany(
      `SELECT id FROM users WHERE user_type = $1 AND status = 'active'`,
      [ROLES.ADMIN]
    );

    const title = "Nouvelle export partenaire";
    const trailerNumber = exportData.trailer_number;

    // Notify agent imports - they need to approve/reject
    for (const agentImport of agentImports) {
      await createNotification({
        type: "export_request",
        title,
        message: `${partenaireName} a créé un export (${trailerNumber}). Action requise.`,
        referenceType: "partenaire_export",
        referenceId: exportData.id,
        senderId: partenaiId,
        recipientId: agentImport.id,
        actionRequired: true,
      });
    }

    // Notify admins - for information only
    for (const admin of admins) {
      await createNotification({
        type: "export_request",
        title,
        message: `${partenaireName} a créé un export (${trailerNumber}).`,
        referenceType: "partenaire_export",
        referenceId: exportData.id,
        senderId: partenaiId,
        recipientId: admin.id,
        actionRequired: false,
      });
    }

    console.log(`📧 Notifications envoyées pour partenaire export #${exportData.id}`);
  } catch (error) {
    console.error("Error notifying partner export creation:", error);
  }
};

/**
 * WORKFLOW 3: Approval Decision Made
 * Partenaire/Agent approves/rejects → Creator + Admin get notified
 */
const notifyApprovalDecision = async (
  requestType, // 'export' or 'import' or 'partenaire_export'
  requestData,
  decisionMakerId,
  decision, // 'approved' or 'rejected'
  reason = null
) => {
  try {
    const decisionMaker = await getOne(
      "SELECT full_name, user_type FROM users WHERE id = $1",
      [decisionMakerId]
    );
    const decisionMakerName = decisionMaker?.full_name || "User";
    const decisionMakerRole = decisionMaker?.user_type;

    // Get all admins
    const admins = await getMany(
      `SELECT id FROM users WHERE user_type = $1 AND status = 'active'`,
      [ROLES.ADMIN]
    );

    const trailerNumber = requestData.trailer_number;
    const isApproved = decision === "approved";

    // Determine message based on request type and decision maker role
    let creatorMessage = "";
    let adminMessage = "";
    let title = "";

    if (isApproved) {
      title = `Demande d'${requestType} approuvée`;
      creatorMessage = `Votre demande d'${requestType} (${trailerNumber}) a été approuvée par ${decisionMakerName}.`;
      adminMessage = `${decisionMakerName} a approuvé la demande d'${requestType} (${trailerNumber}).`;
    } else {
      title = `Demande d'${requestType} refusée`;
      creatorMessage = `Votre demande d'${requestType} (${trailerNumber}) a été refusée par ${decisionMakerName}. ${reason ? `Raison: ${reason}` : ""}`;
      adminMessage = `${decisionMakerName} a refusé la demande d'${requestType} (${trailerNumber}). ${reason ? `Raison: ${reason}` : ""}`;
    }

    // Notify creator
    if (requestData.created_by && requestData.created_by !== decisionMakerId) {
      await createNotification({
        type: isApproved ? "approval" : "rejection",
        title,
        message: creatorMessage,
        referenceType: requestType,
        referenceId: requestData.id,
        senderId: decisionMakerId,
        recipientId: requestData.created_by,
        actionRequired: false,
      });
    }

    // Notify all admins
    for (const admin of admins) {
      if (admin.id !== decisionMakerId) {
        // Don't notify the admin who made the decision
        await createNotification({
          type: "info",
          title: `Mise à jour: ${title}`,
          message: adminMessage,
          referenceType: requestType,
          referenceId: requestData.id,
          senderId: decisionMakerId,
          recipientId: admin.id,
          actionRequired: false,
        });
      }
    }

    console.log(
      `📧 Notifications de décision envoyées pour ${requestType} #${requestData.id}`
    );
  } catch (error) {
    console.error("Error notifying approval decision:", error);
  }
};

module.exports = {
  createNotification,
  notifyAgentExportCreated,
  notifyPartnerExportCreated,
  notifyApprovalDecision,
};
