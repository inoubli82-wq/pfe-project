const { query, getOne } = require("../config/database");

/**
 * Get all transporter stocks
 * GET /api/stocks
 */
const getAllStocks = async (req, res) => {
  try {
    const result = await query("SELECT * FROM stocks ORDER BY transporter ASC");
    res.json({
      success: true,
      data: result.rows,
    });
  } catch (error) {
    console.error("❌ Erreur lors de la récupération des stocks:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur lors de la récupération des stocks",
    });
  }
};

/**
 * Update stock for a specific transporter
 * PUT /api/stocks/:transporter
 */
const updateStock = async (req, res) => {
  const { transporter } = req.params;
  const { bars_count, singles_count, suction_cups_count } = req.body;

  try {
    // Check if stock entry exists
    const existing = await getOne("SELECT id FROM stocks WHERE transporter = $1", [transporter]);
    
    if (!existing) {
      return res.status(404).json({
        success: false,
        message: `Stock non trouvé pour le transporteur: ${transporter}`,
      });
    }

    // Update stock
    const result = await query(
      `UPDATE stocks 
       SET bars_count = $1, singles_count = $2, suction_cups_count = $3, updated_at = CURRENT_TIMESTAMP
       WHERE transporter = $4
       RETURNING *`,
      [bars_count || 0, singles_count || 0, suction_cups_count || 0, transporter]
    );

    res.json({
      success: true,
      message: `Stock mis à jour pour ${transporter}`,
      data: result.rows[0],
    });
  } catch (error) {
    console.error("❌ Erreur lors de la mise à jour du stock:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur lors de la mise à jour du stock",
    });
  }
};

module.exports = {
  getAllStocks,
  updateStock,
};
