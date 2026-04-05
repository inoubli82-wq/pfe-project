// ==============================================
// PARTNER EXPORT CONTROLLER
// ==============================================

const { query } = require("../config/database");
const { validateRequiredFields } = require("../utils/validation");
const {
  notifyPartnerExportCreated,
  notifyApprovalDecision,
} = require("../utils/notificationService");

/**
 * Create a new partner export
 * POST /api/export-data
 */
const createExportData = async (req, res) => {
  try {
    const {
      trailerNumber,
      embarkationDate,
      clientName,
      numberOfBars = 0,
      numberOfStraps = 0,
      numberOfSuctionCups = 0,
    } = req.body;
    const userId = req.user.id;

    // Validate required fields (Vérification simple)
    if (!trailerNumber || !clientName || !embarkationDate) {
      return res.status(400).json({
        success: false,
        message:
          "Veuillez remplir tous les champs obligatoires (N° Remorque, Client, Date).",
      });
    }

    // Insert into database
    const result = await query(
      `INSERT INTO partenaire_export_data 
       (trailer_number, embarkation_date, client_name, number_of_bars, number_of_straps, number_of_suction_cups, created_by, approval_status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [
        trailerNumber,
        embarkationDate,
        clientName,
        numberOfBars,
        numberOfStraps,
        numberOfSuctionCups,
        userId,
        "pending",
      ],
    );

    const exportData = result.rows[0];

    // Trigger notifications asynchronously
    notifyPartnerExportCreated(exportData, userId);

    return res.status(201).json({
      success: true,
      message: "Export créé avec succès",
      data: exportData,
    });
  } catch (error) {
    console.error("❌ Erreur création export partenaire:", error);
    // Remplacement de apiError par une réponse JSON classique
    return res.status(500).json({
      success: false,
      message: "Erreur lors de la création de l'export",
    });
  }
};

/**
 * Get all partner exports
 * GET /api/export-data
 */
const getAllExportData = async (req, res) => {
  try {
    const userId = req.user.id;
    const userType = req.user.user_type;
    let queryText =
      "SELECT * FROM partenaire_export_data ORDER BY created_at DESC";
    let params = [];
    if (userType !== "admin") {
      queryText =
        "SELECT * FROM partenaire_export_data WHERE created_by = $1 ORDER BY created_at DESC";
      params = [userId];
    }
    const result = await query(queryText, params);
    return res.json({
      success: true,
      data: result.rows,
    });
  } catch (error) {
    console.error("❌ Erreur récupération exports partenaire:", error);
    return res.status(500).json({
      success: false,
      message: "Erreur lors de la récupération des exports",
      error: error.message,
    });
  }
};

/**
 * Get single partner export by ID
 * GET /api/export-data/:id
 */
const getExportDataById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const userType = req.user.user_type;
    let queryText = "SELECT * FROM partenaire_export_data WHERE id = $1";
    let params = [id];
    if (userType !== "admin") {
      queryText =
        "SELECT * FROM partenaire_export_data WHERE id = $1 AND created_by = $2";
      params = [id, userId];
    }
    const result = await query(queryText, params);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Action failed" });
    }
    return res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (error) {
    console.error("❌ Erreur récupération export partenaire:", error);
    return res.status(500).json({ success: false, message: "Action failed" });
  }
};

/**
 * Update partner export
 * PUT /api/export-data/:id
 */
const updateExportData = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      trailerNumber,
      embarkationDate,
      clientName,
      numberOfBars,
      numberOfStraps,
      numberOfSuctionCups,
    } = req.body;
    const userId = req.user.id;
    const userType = req.user.user_type;
    // Verify ownership
    if (userType !== "admin") {
      const ownerCheck = await query(
        "SELECT created_by FROM partenaire_export_data WHERE id = $1",
        [id],
      );
      if (
        ownerCheck.rows.length === 0 ||
        ownerCheck.rows[0].created_by !== userId
      ) {
        return res
          .status(403)
          .json({ success: false, message: "Action failed" });
      }
    }
    // Validate if provided
    if (trailerNumber && !validateTrailerNumber(trailerNumber)) {
      return res
        .status(400)
        .json(
          validationError("trailerNumber", "Invalid trailer number format"),
        );
    }
    if (clientName && !validateClientName(clientName)) {
      return res
        .status(400)
        .json(validationError("clientName", "Invalid client name"));
    }
    if (embarkationDate && !validateDateRange(new Date(embarkationDate))) {
      return res
        .status(400)
        .json(validationError("embarkationDate", "Invalid embarkation date"));
    }
    // Update only provided fields
    const updates = [];
    const values = [id];
    let paramIndex = 2;
    if (trailerNumber) {
      updates.push(`trailer_number = $${paramIndex++}`);
      values.push(trailerNumber);
    }
    if (embarkationDate) {
      updates.push(`embarkation_date = $${paramIndex++}`);
      values.push(embarkationDate);
    }
    if (clientName) {
      updates.push(`client_name = $${paramIndex++}`);
      values.push(clientName);
    }
    if (numberOfBars !== undefined && validateCounts(numberOfBars)) {
      updates.push(`number_of_bars = $${paramIndex++}`);
      values.push(numberOfBars);
    }
    if (numberOfStraps !== undefined && validateCounts(numberOfStraps)) {
      updates.push(`number_of_straps = $${paramIndex++}`);
      values.push(numberOfStraps);
    }
    if (
      numberOfSuctionCups !== undefined &&
      validateCounts(numberOfSuctionCups)
    ) {
      updates.push(`number_of_suction_cups = $${paramIndex++}`);
      values.push(numberOfSuctionCups);
    }
    if (updates.length === 0) {
      return res
        .status(400)
        .json(validationError("body", "No valid fields to update"));
    }
    const result = await query(
      `UPDATE partenaire_export_data SET ${updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *`,
      values,
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Action failed" });
    }
    return res.json({
      success: true,
      message: "Export mis à jour avec succès",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("❌ Erreur mise à jour export partenaire:", error);
    return res.status(500).json({ success: false, message: "Action failed" });
  }
};

/**
 * Delete partner export
 * DELETE /api/export-data/:id
 */
const deleteExportData = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const userType = req.user.user_type;
    // Verify ownership
    if (userType !== "admin") {
      const ownerCheck = await query(
        "SELECT created_by FROM partenaire_export_data WHERE id = $1",
        [id],
      );
      if (
        ownerCheck.rows.length === 0 ||
        ownerCheck.rows[0].created_by !== userId
      ) {
        return res
          .status(403)
          .json({ success: false, message: "Action failed" });
      }
    }
    // Only allow deletion if not already approved/rejected
    const stateCheck = await query(
      "SELECT approval_status FROM partenaire_export_data WHERE id = $1",
      [id],
    );
    if (stateCheck.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Action failed" });
    }
    if (stateCheck.rows[0].approval_status !== "pending") {
      return res.status(400).json({
        success: false,
        message: "Cannot delete export that has already been processed",
      });
    }
    const result = await query(
      "DELETE FROM partenaire_export_data WHERE id = $1 RETURNING *",
      [id],
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Action failed" });
    }
    return res.json({
      success: true,
      message: "Export supprimé avec succès",
      data: result.rows[0],
    });
  } catch (error) {
    console.error("❌ Erreur suppression export partenaire:", error);
    return res.status(500).json({ success: false, message: "Action failed" });
  }
};

/**
 * PUT /api/partenaire-exports/:id/approve
 */
const approveExportData = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    // Get export
    const result = await query(
      "SELECT * FROM partenaire_export_data WHERE id = $1",
      [id],
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Action failed" });
    }
    const exportData = result.rows[0];
    if (exportData.approval_status !== "pending") {
      return res.status(400).json({ success: false, message: "Action failed" });
    }
    // Update approval
    const updatedResult = await query(
      `UPDATE partenaire_export_data SET approval_status = 'approved', approved_by = $1, approved_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *`,
      [userId, id],
    );
    const updatedData = updatedResult.rows[0];
    // Trigger notifications
    notifyApprovalDecision(
      "partenaire_export",
      updatedData,
      userId,
      "approved",
    );
    return res.json({
      success: true,
      message: "Export approuvé avec succès",
      data: {
        id: updatedData.id,
        approvalStatus: updatedData.approval_status,
        approvedBy: updatedData.approved_by,
        approvedAt: updatedData.approved_at,
      },
    });
  } catch (error) {
    console.error("Erreur approbation export partenaire:", error);
    return res.status(500).json({ success: false, message: "Action failed" });
  }
};

/**
 * PUT /api/partenaire-exports/:id/reject
 */
const rejectExportData = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { reason } = req.body;
    if (!reason || reason.trim().length === 0) {
      return res
        .status(400)
        .json(validationError("reason", "Rejection reason is required"));
    }
    // Get export
    const result = await query(
      "SELECT * FROM partenaire_export_data WHERE id = $1",
      [id],
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Action failed" });
    }
    const exportData = result.rows[0];
    if (exportData.approval_status !== "pending") {
      return res.status(400).json({ success: false, message: "Action failed" });
    }
    // Update rejection
    const updatedResult = await query(
      `UPDATE partenaire_export_data SET approval_status = 'rejected', approved_by = $1, approved_at = CURRENT_TIMESTAMP, rejection_reason = $2 WHERE id = $3 RETURNING *`,
      [userId, reason, id],
    );
    const updatedData = updatedResult.rows[0];
    // Trigger notifications
    notifyApprovalDecision(
      "partenaire_export",
      updatedData,
      userId,
      "rejected",
      reason,
    );
    return res.json({
      success: true,
      message: "Export rejeté avec succès",
      data: {
        id: updatedData.id,
        approvalStatus: updatedData.approval_status,
        approvedBy: updatedData.approved_by,
        approvedAt: updatedData.approved_at,
        rejectionReason: updatedData.rejection_reason,
      },
    });
  } catch (error) {
    console.error("Erreur rejet export partenaire:", error);
    return res.status(500).json({ success: false, message: "Action failed" });
  }
};

module.exports = {
  createExportData,
  getAllExportData,
  getExportDataById,
  updateExportData,
  deleteExportData,
  approveExportData,
  rejectExportData,
};
