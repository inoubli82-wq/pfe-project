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
    const totalUsers = await getOne("SELECT COUNT(*) FROM users");
    const admins = await getOne(
      "SELECT COUNT(*) FROM users WHERE user_type = $1",
      [ROLES.ADMIN],
    );
    const agentsExport = await getOne(
      "SELECT COUNT(*) FROM users WHERE user_type = $1",
      [ROLES.AGENT_EXPORT],
    );
    const agentsImport = await getOne(
      "SELECT COUNT(*) FROM users WHERE user_type = $1",
      [ROLES.AGENT_IMPORT],
    );
    const partenaires = await getOne(
      "SELECT COUNT(*) FROM users WHERE user_type = $1",
      [ROLES.PARTENAIRE],
    );
    const totalExports = await getOne("SELECT COUNT(*) FROM exports");
    const totalImports = await getOne("SELECT COUNT(*) FROM imports");
    const pendingExports = await getOne(
      "SELECT COUNT(*) FROM exports WHERE approval_status = 'pending'",
    );
    const pendingImports = await getOne(
      "SELECT COUNT(*) FROM imports WHERE approval_status = 'pending'",
    );
    const approvedExports = await getOne(
      "SELECT COUNT(*) FROM exports WHERE approval_status = 'approved'",
    );
    const approvedImports = await getOne(
      "SELECT COUNT(*) FROM imports WHERE approval_status = 'approved'",
    );

    res.json({
      success: true,
      message: "Dashboard Admin",
      stats: {
        totalUsers: parseInt(totalUsers.count),
        usersByRole: {
          admins: parseInt(admins.count),
          agentsExport: parseInt(agentsExport.count),
          agentsImport: parseInt(agentsImport.count),
          partenaires: parseInt(partenaires.count),
        },
        totalExports: parseInt(totalExports.count),
        totalImports: parseInt(totalImports.count),
        pendingRequests: {
          exports: parseInt(pendingExports.count),
          imports: parseInt(pendingImports.count),
          total:
            parseInt(pendingExports.count) + parseInt(pendingImports.count),
        },
        approvedRequests: {
          exports: parseInt(approvedExports.count),
          imports: parseInt(approvedImports.count),
        },
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
      message: "Erreur serveur",
    });
  }
};

module.exports = {
  getAllUsers,
  getDashboardStats,
  createUser,
  updateUserStatus,
  deleteUser,
};
