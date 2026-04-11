// ==============================================
// EXPORT CONTROLLER
// ==============================================

const { query, getOne, getMany } = require("../config/database");
const { notifyForNewRequest } = require("./notificationController");

/**
 * Create a new export
 * POST /api/exports
 */
const createExport = async (req, res) => {
  const {
    trailerNumber,
    date,
    clientName,
    country,
    transporter,
    barsCount,
    singlesCount,
    notes,
  } = req.body;

  try {
    if (!trailerNumber || !date || !clientName || !country) {
      return res.status(400).json({
        success: false,
        message: "Champs obligatoires manquants",
      });
    }

    const result = await query(
      `INSERT INTO exports (trailer_number, export_date, client_name, country, transporter, bars_count, singles_count, notes, created_by, status, approval_status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'pending', 'pending')
       RETURNING *`,
      [
        trailerNumber,
        date,
        clientName,
        country,
        transporter || null,
        barsCount || 0,
        singlesCount || 0,
        notes || "",
        req.user.id,
      ],
    );

    const newExport = result.rows[0];

    // Send notifications to partenaire and admin
    await notifyForNewRequest("export", newExport, req.user.id);

    console.log(`✅ Export créé par ${req.user.email}: ${trailerNumber}`);

    res.status(201).json({
      success: true,
      message: "Export créé avec succès. Notification envoyée au partenaire.",
      export: newExport,
    });
  } catch (error) {
    console.error("Error creating export:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Get all exports
 * GET /api/exports
 */
const getAllExports = async (req, res) => {
  try {
    const exports = await getMany(`
      SELECT e.*, u.full_name as created_by_name 
      FROM exports e 
      LEFT JOIN users u ON e.created_by = u.id 
      ORDER BY e.created_at DESC
    `);

    res.json({
      success: true,
      count: exports.length,
      exports,
    });
  } catch (error) {
    console.error("Error fetching exports:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Get single export by ID
 * GET /api/exports/:id
 */
const getExportById = async (req, res) => {
  try {
    const exportItem = await getOne(
      `SELECT e.*, u.full_name as created_by_name 
       FROM exports e 
       LEFT JOIN users u ON e.created_by = u.id 
       WHERE e.id = $1`,
      [req.params.id],
    );

    if (!exportItem) {
      return res.status(404).json({
        success: false,
        message: "Export non trouvé",
      });
    }

    res.json({
      success: true,
      export: exportItem,
    });
  } catch (error) {
    console.error("Error fetching export:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Update export status
 * PATCH /api/exports/:id/status
 */
const updateExportStatus = async (req, res) => {
  const { status } = req.body;

  try {
    const validStatuses = ["pending", "in_progress", "completed", "cancelled"];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Statut invalide",
      });
    }

    const result = await query(
      "UPDATE exports SET status = $1 WHERE id = $2 RETURNING *",
      [status, req.params.id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Export non trouvé",
      });
    }

    res.json({
      success: true,
      message: "Statut mis à jour",
      export: result.rows[0],
    });
  } catch (error) {
    console.error("Error updating export status:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Delete export
 * DELETE /api/exports/:id
 */
const deleteExport = async (req, res) => {
  try {
    const result = await query(
      "DELETE FROM exports WHERE id = $1 RETURNING id",
      [req.params.id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Export non trouvé",
      });
    }

    res.json({
      success: true,
      message: "Export supprimé",
    });
  } catch (error) {
    console.error("Error deleting export:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

module.exports = {
  createExport,
  getAllExports,
  getExportById,
  updateExportStatus,
  deleteExport,
};
