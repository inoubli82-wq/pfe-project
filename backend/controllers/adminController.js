// ==============================================
// ADMIN CONTROLLER
// ==============================================

const bcrypt = require("bcryptjs");
const { query, getOne, getMany } = require("../config/database");
const { ROLES } = require("../config/roles");
const { formatUser } = require("../utils/helpers");

const SALT_ROUNDS = 10;

/**
 * Get all users
 * GET /api/admin/users
 */
const getAllUsers = async (req, res) => {
  try {
    const users = await getMany(
      "SELECT id, full_name, email, phone, country_code, user_type, status, created_at FROM users ORDER BY created_at DESC",
    );

    res.json({
      success: true,
      count: users.length,
      users: users.map(formatUser),
    });
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Get admin dashboard stats
 * GET /api/admin/dashboard
 */
const getDashboardStats = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    // Add date filtering for exports/imports if dates are provided
    let dateFilterExport = "";
    let dateFilterImport = "";
    let params = [];
    
    if (startDate && endDate) {
      dateFilterExport = " AND export_date BETWEEN $1 AND $2";
      dateFilterImport = " AND import_date BETWEEN $1 AND $2";
      params = [startDate, endDate];
    }

    const totalUsers = await getOne("SELECT COUNT(*) FROM users");
    const admins = await getOne("SELECT COUNT(*) FROM users WHERE user_type = 'admin'");
    const agentsExport = await getOne("SELECT COUNT(*) FROM users WHERE user_type = 'Agent Export'");
    const agentsImport = await getOne("SELECT COUNT(*) FROM users WHERE user_type = 'Agent Import'");
    const agentsStock = await getOne("SELECT COUNT(*) FROM users WHERE user_type = 'Agent de Stock'");
    const partenaires = await getOne("SELECT COUNT(*) FROM users WHERE user_type = 'Partenaire'");
    
    // Total exports/imports count
    const totalExports = await getOne(`SELECT COUNT(*) FROM exports WHERE 1=1 ${dateFilterExport}`, params);
    const totalImports = await getOne(`SELECT COUNT(*) FROM imports WHERE 1=1 ${dateFilterImport}`, params);

    // Bars/Items pending and approved
    const pendingExports = await getOne(`SELECT COALESCE(SUM(bars_count), 0) as total FROM exports WHERE approval_status = 'pending' ${dateFilterExport}`, params);
    const pendingImports = await getOne(`SELECT COALESCE(SUM(items_count), 0) as total FROM imports WHERE approval_status = 'pending' ${dateFilterImport}`, params);
    
    const approvedExports = await getOne(`SELECT COALESCE(SUM(bars_count), 0) as total FROM exports WHERE approval_status = 'approved' ${dateFilterExport}`, params);
    const approvedImports = await getOne(`SELECT COALESCE(SUM(items_count), 0) as total FROM imports WHERE approval_status = 'approved' ${dateFilterImport}`, params);
    
    // Total historical bars (for Tunisia calculation if needed)
    const allTimeExportsBars = await getOne(`SELECT COALESCE(SUM(bars_count), 0) as total FROM exports WHERE 1=1 ${dateFilterExport}`, params);

    // Get Stocks per company
    const stocksResult = await query("SELECT transporter, singles_count, suction_cups_count FROM stocks ORDER BY transporter ASC");

    // Aggregate stats
    const barsEnCours = parseInt(pendingExports.total) + parseInt(pendingImports.total);
    const barsConfirmed = parseInt(approvedExports.total) + parseInt(approvedImports.total);
    const totalBars = parseInt(allTimeExportsBars.total);
    const barsTunisia = Math.max(0, totalBars - barsEnCours - barsConfirmed);

    res.json({
      success: true,
      message: "Dashboard Admin",
      stats: {
        users: {
          total: parseInt(totalUsers.count),
          admins: parseInt(admins.count),
          agentsExport: parseInt(agentsExport.count),
          agentsImport: parseInt(agentsImport.count),
          agentsStock: parseInt(agentsStock.count),
          partenaires: parseInt(partenaires.count),
        },
        counts: {
          exports: parseInt(totalExports.count),
          imports: parseInt(totalImports.count),
        },
        bars: {
          enCours: barsEnCours,
          confirmed: barsConfirmed,
          tunisia: barsTunisia,
          total: totalBars,
          pendingExports: parseInt(pendingExports.total),
          pendingImports: parseInt(pendingImports.total)
        },
        stocks: stocksResult.rows
      },
    });
  } catch (error) {
    console.error("Error fetching dashboard:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Create a new user (Admin can create any role)
 * POST /api/admin/users
 */
const createUser = async (req, res) => {
  const { fullName, email, phone, countryCode, userType, password } = req.body;

  try {
    if (!fullName || !email || !userType || !password) {
      return res.status(400).json({
        success: false,
        message: "Champs obligatoires manquants",
      });
    }

    const existingUser = await getOne("SELECT id FROM users WHERE email = $1", [
      email,
    ]);
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: "Un compte existe déjà avec cet email",
      });
    }

    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    const result = await query(
      `INSERT INTO users (full_name, email, phone, country_code, user_type, password, status)
       VALUES ($1, $2, $3, $4, $5, $6, 'active')
       RETURNING *`,
      [
        fullName,
        email,
        phone || "",
        countryCode || "+216",
        userType,
        hashedPassword,
      ],
    );

    console.log(`✅ Admin créé utilisateur: ${email} (${userType})`);

    res.status(201).json({
      success: true,
      message: `Utilisateur ${userType} créé`,
      user: formatUser(result.rows[0]),
    });
  } catch (error) {
    console.error("Error creating user:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Update user status
 * PATCH /api/admin/users/:id/status
 */
const updateUserStatus = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  try {
    const validStatuses = ["active", "inactive", "suspended"];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: "Statut invalide",
      });
    }

    const result = await query(
      "UPDATE users SET status = $1 WHERE id = $2 RETURNING *",
      [status, id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Utilisateur non trouvé",
      });
    }

    res.json({
      success: true,
      message: "Statut mis à jour",
      user: formatUser(result.rows[0]),
    });
  } catch (error) {
    console.error("Error updating user status:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Update user role
 * PATCH /api/admin/users/:id/role
 */
const updateUserRole = async (req, res) => {
  const { id } = req.params;
  const { userType } = req.body;

  try {
    const validRoles = [
      ROLES.ADMIN,
      ROLES.AGENT_EXPORT,
      ROLES.AGENT_IMPORT,
      ROLES.PARTENAIRE,
    ];
    if (!validRoles.includes(userType)) {
      return res.status(400).json({
        success: false,
        message: "Rôle invalide",
      });
    }

    // Prevent changing own role
    if (parseInt(id) === req.user.id) {
      return res.status(400).json({
        success: false,
        message: "Vous ne pouvez pas modifier votre propre rôle",
      });
    }

    const result = await query(
      "UPDATE users SET user_type = $1 WHERE id = $2 RETURNING *",
      [userType, id],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Utilisateur non trouvé",
      });
    }

    res.json({
      success: true,
      message: "Rôle mis à jour",
      user: formatUser(result.rows[0]),
    });
  } catch (error) {
    console.error("Error updating user role:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Delete user
 * DELETE /api/admin/users/:id
 */
const deleteUser = async (req, res) => {
  const { id } = req.params;

  try {
    // Prevent self-deletion
    if (parseInt(id) === req.user.id) {
      return res.status(400).json({
        success: false,
        message: "Vous ne pouvez pas supprimer votre propre compte",
      });
    }

    // Remove/nullify references to avoid foreign key constraints
    // (in case the DB doesn't have ON DELETE SET NULL configured properly)
    await query("UPDATE exports SET created_by = NULL WHERE created_by = $1", [id]);
    await query("UPDATE exports SET approved_by = NULL WHERE approved_by = $1", [id]);
    
    await query("UPDATE imports SET created_by = NULL WHERE created_by = $1", [id]);
    await query("UPDATE imports SET approved_by = NULL WHERE approved_by = $1", [id]);
    
    await query("UPDATE partenaire_export_data SET created_by = NULL WHERE created_by = $1", [id]);
    await query("UPDATE partenaire_export_data SET approved_by = NULL WHERE approved_by = $1", [id]);
    
    await query("DELETE FROM notifications WHERE recipient_id = $1", [id]);
    await query("UPDATE notifications SET sender_id = NULL WHERE sender_id = $1", [id]);

    const result = await query("DELETE FROM users WHERE id = $1 RETURNING id", [
      id,
    ]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Utilisateur non trouvé",
      });
    }

    res.json({
      success: true,
      message: "Utilisateur supprimé",
    });
  } catch (error) {
    console.error("Error deleting user:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur: Impossible de supprimer l'utilisateur. Vérifiez les dépendances.",
    });
  }
};

module.exports = {
  getAllUsers,
  getDashboardStats,
  createUser,
  updateUserStatus,
  updateUserRole,
  deleteUser,
};
