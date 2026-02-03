// ==============================================
// HELPER FUNCTIONS
// ==============================================

/**
 * Generate a JWT-like token for authentication
 * @param {Object} user - User object from database
 * @returns {string} Generated token
 */
const generateToken = (user) => {
  return `jwt-${user.user_type.replace(" ", "")}-${user.id}-${Date.now()}`;
};

/**
 * Format user object for API response (remove sensitive data)
 * @param {Object} dbUser - User object from database
 * @returns {Object} Formatted user object
 */
const formatUser = (dbUser) => ({
  id: dbUser.id,
  fullName: dbUser.full_name,
  email: dbUser.email,
  phone: dbUser.phone,
  countryCode: dbUser.country_code,
  userType: dbUser.user_type,
  transporter: dbUser.transporter,
  status: dbUser.status,
  createdAt: dbUser.created_at,
});

/**
 * Extract user ID from authentication token
 * @param {string} token - JWT-like token
 * @returns {number|null} User ID or null
 */
const extractUserIdFromToken = (token) => {
  try {
    const tokenParts = token.split("-");
    return parseInt(tokenParts[2]);
  } catch {
    return null;
  }
};

module.exports = {
  generateToken,
  formatUser,
  extractUserIdFromToken,
};
