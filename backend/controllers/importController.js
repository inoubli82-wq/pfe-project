// ==============================================
// IMPORT CONTROLLER
// ==============================================

const { query, getOne, getMany } = require("../config/database");
const { notifyForNewRequest } = require("./notificationController");

/**
 * Create a new import
 * POST /api/imports
 */
const createImport = async (req, res) => {
  const {
    trailerNumber,
    date,
    supplierName,
    country,
    transporter,
    itemsCount,
    notes,
  } = req.body;

  try {
    if (!trailerNumber || !date || !supplierName || !country) {
      return res.status(400).json({
        success: false,
        message: "Champs obligatoires manquants",
      });
    }

    const result = await query(
      `INSERT INTO imports (trailer_number, import_date, supplier_name, country, transporter, items_count, notes, created_by, status, approval_status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'pending', 'pending')
       RETURNING *`,
      [
        trailerNumber,
        date,
        supplierName,
        country,
        transporter || "",
        itemsCount || 0,
        notes || "",
        req.user.id,
      ],
    );

    const newImport = result.rows[0];

    // Send notifications to partenaire and admin
    await notifyForNewRequest("import", newImport, req.user.id);

    console.log(`✅ Import créé par ${req.user.email}: ${trailerNumber}`);

    res.status(201).json({
      success: true,
      message: "Import créé avec succès. Notification envoyée au partenaire.",
      import: newImport,
    });
  } catch (error) {
    console.error("Error creating import:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Get all imports
 * GET /api/imports
 */
const getAllImports = async (req, res) => {
  try {
    const imports = await getMany(`
      SELECT i.*, u.full_name as created_by_name 
      FROM imports i 
      LEFT JOIN users u ON i.created_by = u.id 
      ORDER BY i.created_at DESC
    `);

    res.json({
      success: true,
      count: imports.length,
      imports,
    });
  } catch (error) {
    console.error("Error fetching imports:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Get single import by ID
 * GET /api/imports/:id
 */
const getImportById = async (req, res) => {
  try {
    const importItem = await getOne(
      `SELECT i.*, u.full_name as created_by_name 
       FROM imports i 
       LEFT JOIN users u ON i.created_by = u.id 
       WHERE i.id = $1`,
      [req.params.id],
    );

    if (!importItem) {
      return res.status(404).json({
        success: false,
        message: "Import non trouvé",
      });
    }

    res.json({
      success: true,
      import: importItem,
    });
  } catch (error) {
    console.error("Error fetching import:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Update import status
 * PATCH /api/imports/:id/status
 */
const updateImportStatus = async (req, res) => {
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
      "UPDATE imports SET status = $1 WHERE id = $2 RETURNING *",
      [status, req.params.id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Import non trouvé",
      });
    }

    res.json({
      success: true,
      message: "Statut mis à jour",
      import: result.rows[0],
    });
  } catch (error) {
    console.error("Error updating import status:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Delete import
 * DELETE /api/imports/:id
 */
const deleteImport = async (req, res) => {
  try {
    const result = await query(
      "DELETE FROM imports WHERE id = $1 RETURNING id",
      [req.params.id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Import non trouvé",
      });
    }

    res.json({
      success: true,
      message: "Import supprimé",
    });
  } catch (error) {
    console.error("Error deleting import:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

module.exports = {
  createImport,
  getAllImports,
  getImportById,
  updateImportStatus,
  deleteImport,
};
