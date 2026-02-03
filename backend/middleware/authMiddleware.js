// ==============================================
// AUTHENTICATION MIDDLEWARE
// ==============================================

const { getOne } = require("../config/database");
const { extractUserIdFromToken } = require("../utils/helpers");

/**
 * Middleware to check if user has required role
 * @param  {...string} allowedRoles - Roles that are allowed to access the route
 * @returns {Function} Express middleware function
 */
const checkRole = (...allowedRoles) => {
  return async (req, res, next) => {
    const token = req.headers.authorization?.replace("Bearer ", "");

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Token manquant",
      });
    }

    try {
      // Extract user ID from token
      const userId = extractUserIdFromToken(token);

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: "Token invalide",
        });
      }

      // Get user from database
      const user = await getOne("SELECT * FROM users WHERE id = $1", [userId]);

      if (!user) {
        return res.status(401).json({
          success: false,
          message: "Utilisateur non trouvé",
        });
      }

      // Check if user has allowed role
      if (!allowedRoles.includes(user.user_type)) {
        return res.status(403).json({
          success: false,
          message: "Accès non autorisé pour votre rôle",
          requiredRoles: allowedRoles,
          userRole: user.user_type,
        });
      }

      req.user = user;
      next();
    } catch (error) {
      console.error("Auth error:", error);
      res.status(500).json({
        success: false,
        message: "Erreur d'authentification",
      });
    }
  };
};

/**
 * Middleware to authenticate user without role check
 * Extracts user from token and attaches to request
 */
const authenticate = async (req, res, next) => {
  const token = req.headers.authorization?.replace("Bearer ", "");

  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Token manquant",
    });
  }

  try {
    const userId = extractUserIdFromToken(token);

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Token invalide",
      });
    }

    const user = await getOne("SELECT * FROM users WHERE id = $1", [userId]);

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Utilisateur non trouvé",
      });
    }

    req.user = user;
    next();
  } catch (error) {
    console.error("Auth error:", error);
    res.status(500).json({
      success: false,
      message: "Erreur d'authentification",
    });
  }
};

module.exports = {
  checkRole,
  authenticate,
};
