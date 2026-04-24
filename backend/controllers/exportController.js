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
    suctionCupsCount,
    notes,
  } = req.body;

  const { pool } = require("../config/database");
  const client = await pool.connect();

  try {
    if (!trailerNumber || !date || !clientName || !country || !transporter) {
      return res.status(400).json({
        success: false,
        message: "Champs obligatoires manquants (numéro, date, client, pays et transporteur)",
      });
    }

    await client.query('BEGIN');

    // 1. Check stock
    const stockResult = await client.query(
      "SELECT * FROM stocks WHERE transporter = $1 FOR UPDATE",
      [transporter]
    );

    if (stockResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        message: `Aucun stock configuré pour le transporteur: ${transporter}`,
      });
    }

    const currentStock = stockResult.rows[0];
    const requestedBars = barsCount || 0;
    const requestedSingles = singlesCount || 0;
    const requestedSuctionCups = suctionCupsCount || 0;

    if (currentStock.bars_count < requestedBars || 
        currentStock.singles_count < requestedSingles || 
        currentStock.suction_cups_count < requestedSuctionCups) {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        message: "Stock insuffisant pour cette commande",
        availableStock: {
          bars: currentStock.bars_count,
          singles: currentStock.singles_count,
          suctionCups: currentStock.suction_cups_count
        }
      });
    }

    // 2. Deduct from stock
    await client.query(
      `UPDATE stocks 
       SET bars_count = bars_count - $1, 
           singles_count = singles_count - $2, 
           suction_cups_count = suction_cups_count - $3,
           updated_at = CURRENT_TIMESTAMP
       WHERE transporter = $4`,
      [requestedBars, requestedSingles, requestedSuctionCups, transporter]
    );

    // 3. Create export
    const result = await client.query(
      `INSERT INTO exports (trailer_number, export_date, client_name, country, transporter, bars_count, singles_count, suction_cups_count, notes, created_by, status, approval_status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'pending', 'pending')
       RETURNING *`,
      [
        trailerNumber,
        date,
        clientName,
        country,
        transporter,
        requestedBars,
        requestedSingles,
        requestedSuctionCups,
        notes || "",
        req.user.id,
      ],
    );

    const newExport = result.rows[0];

    await client.query('COMMIT');

    // Send notifications to partenaire and admin
    await notifyForNewRequest("export", newExport, req.user.id);

    console.log(`✅ Export créé et stock mis à jour par ${req.user.email}: ${trailerNumber}`);

    res.status(201).json({
      success: true,
      message: "Export créé et stock déduit avec succès.",
      export: newExport,
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error creating export:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur lors de la création de l'export",
    });
  } finally {
    client.release();
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
  const { id } = req.params;
  const { pool } = require("../config/database");
  const client = await pool.connect();

  try {
    const validStatuses = ["pending", "in_progress", "completed", "cancelled"];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Statut invalide",
      });
    }

    await client.query('BEGIN');

    // Get current export to see if we need to restore stock
    const currentResult = await client.query("SELECT * FROM exports WHERE id = $1", [id]);
    if (currentResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: "Export non trouvé",
      });
    }
    const currentExport = currentResult.rows[0];

    // If changing TO cancelled from something NOT cancelled, restore stock
    if (status === 'cancelled' && currentExport.status !== 'cancelled') {
      if (currentExport.transporter) {
        await client.query(
          `UPDATE stocks 
           SET bars_count = bars_count + $1, 
               singles_count = singles_count + $2, 
               suction_cups_count = suction_cups_count + $3,
               updated_at = CURRENT_TIMESTAMP
           WHERE transporter = $4`,
          [
            currentExport.bars_count || 0, 
            currentExport.singles_count || 0, 
            currentExport.suction_cups_count || 0, 
            currentExport.transporter
          ]
        );
      }
    } 
    // If changing FROM cancelled to something ELSE, deduct stock again
    else if (status !== 'cancelled' && currentExport.status === 'cancelled') {
      // Check if stock is available
      const stockResult = await client.query(
        "SELECT * FROM stocks WHERE transporter = $1 FOR UPDATE",
        [currentExport.transporter]
      );

      if (stockResult.rows.length > 0) {
        const stock = stockResult.rows[0];
        if (stock.bars_count < currentExport.bars_count || 
            stock.singles_count < currentExport.singles_count || 
            stock.suction_cups_count < currentExport.suction_cups_count) {
          await client.query('ROLLBACK');
          return res.status(400).json({
            success: false,
            message: "Impossible de restaurer l'export: stock insuffisant",
          });
        }

        await client.query(
          `UPDATE stocks 
           SET bars_count = bars_count - $1, 
               singles_count = singles_count - $2, 
               suction_cups_count = suction_cups_count - $3,
               updated_at = CURRENT_TIMESTAMP
           WHERE transporter = $4`,
          [
            currentExport.bars_count || 0, 
            currentExport.singles_count || 0, 
            currentExport.suction_cups_count || 0, 
            currentExport.transporter
          ]
        );
      }
    }

    const result = await client.query(
      "UPDATE exports SET status = $1 WHERE id = $2 RETURNING *",
      [status, id],
    );

    await client.query('COMMIT');

    res.json({
      success: true,
      message: "Statut mis à jour",
      export: result.rows[0],
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error updating export status:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  } finally {
    client.release();
  }
};

/**
 * Update export details
 * PUT /api/exports/:id
 */
const updateExport = async (req, res) => {
  const { id } = req.params;
  const {
    trailerNumber,
    date,
    clientName,
    country,
    transporter,
    barsCount,
    singlesCount,
    suctionCupsCount,
    notes,
  } = req.body;

  const { pool } = require("../config/database");
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // 1. Get current export to calculate difference
    const currentResult = await client.query("SELECT * FROM exports WHERE id = $1 FOR UPDATE", [id]);
    if (currentResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: "Export non trouvé",
      });
    }
    const current = currentResult.rows[0];

    // Check if status allows editing (only pending or if admin)
    if (current.status !== 'pending' && req.user.user_type !== 'admin') {
      await client.query('ROLLBACK');
      return res.status(400).json({
        success: false,
        message: "Impossible de modifier un export déjà en cours ou terminé",
      });
    }

    const newBars = barsCount || 0;
    const newSingles = singlesCount || 0;
    const newSuctionCups = suctionCupsCount || 0;

    const diffBars = newBars - (current.bars_count || 0);
    const diffSingles = newSingles - (current.singles_count || 0);
    const diffSuctionCups = newSuctionCups - (current.suction_cups_count || 0);

    // 2. Adjust stock if counts changed
    if (diffBars !== 0 || diffSingles !== 0 || diffSuctionCups !== 0) {
      const transporterToUpdate = transporter || current.transporter;
      
      // If transporter changed, we need to restore to old and deduct from new
      if (transporter && current.transporter && transporter !== current.transporter) {
        // Restore to old transporter
        await client.query(
          `UPDATE stocks 
           SET bars_count = bars_count + $1, 
               singles_count = singles_count + $2, 
               suction_cups_count = suction_cups_count + $3
           WHERE transporter = $4`,
          [current.bars_count || 0, current.singles_count || 0, current.suction_cups_count || 0, current.transporter]
        );

        // Deduct from new transporter
        const newStockResult = await client.query(
          "SELECT * FROM stocks WHERE transporter = $1 FOR UPDATE",
          [transporter]
        );

        if (newStockResult.rows.length === 0) {
          await client.query('ROLLBACK');
          return res.status(400).json({
            success: false,
            message: `Nouveau transporteur ${transporter} non trouvé dans les stocks`,
          });
        }

        const newStock = newStockResult.rows[0];
        if (newStock.bars_count < newBars || newStock.singles_count < newSingles || newStock.suction_cups_count < newSuctionCups) {
          await client.query('ROLLBACK');
          return res.status(400).json({
            success: false,
            message: "Stock insuffisant chez le nouveau transporteur",
          });
        }

        await client.query(
          `UPDATE stocks 
           SET bars_count = bars_count - $1, 
               singles_count = singles_count - $2, 
               suction_cups_count = suction_cups_count - $3
           WHERE transporter = $4`,
          [newBars, newSingles, newSuctionCups, transporter]
        );
      } 
      // Same transporter, just adjust diff
      else {
        const stockResult = await client.query(
          "SELECT * FROM stocks WHERE transporter = $1 FOR UPDATE",
          [transporterToUpdate]
        );

        if (stockResult.rows.length > 0) {
          const stock = stockResult.rows[0];
          // If we need MORE items, check if available
          if ((diffBars > 0 && stock.bars_count < diffBars) || 
              (diffSingles > 0 && stock.singles_count < diffSingles) || 
              (diffSuctionCups > 0 && stock.suction_cups_count < diffSuctionCups)) {
            await client.query('ROLLBACK');
            return res.status(400).json({
              success: false,
              message: "Stock insuffisant pour les modifications demandées",
            });
          }

          await client.query(
            `UPDATE stocks 
             SET bars_count = bars_count - $1, 
                 singles_count = singles_count - $2, 
                 suction_cups_count = suction_cups_count - $3,
                 updated_at = CURRENT_TIMESTAMP
             WHERE transporter = $4`,
            [diffBars, diffSingles, diffSuctionCups, transporterToUpdate]
          );
        }
      }
    }

    // 3. Update export record
    const result = await client.query(
      `UPDATE exports 
       SET trailer_number = COALESCE($1, trailer_number),
           export_date = COALESCE($2, export_date),
           client_name = COALESCE($3, client_name),
           country = COALESCE($4, country),
           transporter = COALESCE($5, transporter),
           bars_count = $6,
           singles_count = $7,
           suction_cups_count = $8,
           notes = COALESCE($9, notes),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $10
       RETURNING *`,
      [trailerNumber, date, clientName, country, transporter, newBars, newSingles, newSuctionCups, notes, id]
    );

    await client.query('COMMIT');

    res.json({
      success: true,
      message: "Export mis à jour avec succès",
      export: result.rows[0],
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error updating export:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur lors de la mise à jour",
    });
  } finally {
    client.release();
  }
};

/**
 * Delete export
 * DELETE /api/exports/:id
 */
const deleteExport = async (req, res) => {
  const { id } = req.params;
  const { pool } = require("../config/database");
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // Get current export to restore stock if it wasn't cancelled
    const currentResult = await client.query("SELECT * FROM exports WHERE id = $1", [id]);
    if (currentResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({
        success: false,
        message: "Export non trouvé",
      });
    }
    const currentExport = currentResult.rows[0];

    // Restore stock if the export wasn't already cancelled (stock was already restored then)
    if (currentExport.status !== 'cancelled' && currentExport.transporter) {
      await client.query(
        `UPDATE stocks 
         SET bars_count = bars_count + $1, 
             singles_count = singles_count + $2, 
             suction_cups_count = suction_cups_count + $3,
             updated_at = CURRENT_TIMESTAMP
         WHERE transporter = $4`,
        [
          currentExport.bars_count || 0, 
          currentExport.singles_count || 0, 
          currentExport.suction_cups_count || 0, 
          currentExport.transporter
        ]
      );
    }

    await client.query("DELETE FROM exports WHERE id = $1", [id]);

    await client.query('COMMIT');

    res.json({
      success: true,
      message: "Export supprimé et stock restauré",
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error deleting export:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur lors de la suppression",
    });
  } finally {
    client.release();
  }
};

/**
 * Update arrival info (Transporter sets container and arrival date)
 * PATCH /api/exports/:id/arrival
 */
const updateArrivalInfo = async (req, res) => {
  const { id } = req.params;
  const { containerNumber, expectedArrivalDate } = req.body;

  try {
    const result = await query(
      `UPDATE exports 
       SET container_number = $1, 
           expected_arrival_date = $2, 
           status = 'arrived',
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $3 RETURNING *`,
      [containerNumber, expectedArrivalDate, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Export non trouvé",
      });
    }

    res.json({
      success: true,
      message: "Informations d'arrivée enregistrées",
      export: result.rows[0],
    });
  } catch (error) {
    console.error("Error updating arrival info:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Receive export (Agent Import confirms reception and restores stock)
 * PATCH /api/exports/:id/receive
 */
const receiveExport = async (req, res) => {
  const { id } = req.params;
  const { receivedBars, receivedSingles, receivedSuctionCups, notes } = req.body;
  const { pool } = require("../config/database");
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // Get export info
    const exportResult = await client.query("SELECT * FROM exports WHERE id = $1 FOR UPDATE", [id]);
    if (exportResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ success: false, message: "Export non trouvé" });
    }
    const exportData = exportResult.rows[0];

    // Update export with received counts
    const updatedExport = await client.query(
      `UPDATE exports 
       SET received_bars = $1, 
           received_singles = $2, 
           received_suction_cups = $3, 
           status = 'received',
           notes = $4,
           actual_arrival_date = CURRENT_DATE,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $5 RETURNING *`,
      [receivedBars, receivedSingles, receivedSuctionCups, notes, id]
    );

    // Restore stock to the transporter
    await client.query(
      `UPDATE stocks 
       SET bars_count = bars_count + $1, 
           singles_count = singles_count + $2, 
           suction_cups_count = suction_cups_count + $3,
           updated_at = CURRENT_TIMESTAMP
       WHERE transporter = $4`,
      [receivedBars, receivedSingles, receivedSuctionCups, exportData.transporter]
    );

    await client.query('COMMIT');

    res.json({
      success: true,
      message: "Réception confirmée et stock mis à jour",
      export: updatedExport.rows[0],
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error receiving export:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur lors de la réception",
    });
  } finally {
    client.release();
  }
};

module.exports = {
  createExport,
  getAllExports,
  getExportById,
  updateExportStatus,
  updateExport,
  deleteExport,
  updateArrivalInfo,
  receiveExport,
};
