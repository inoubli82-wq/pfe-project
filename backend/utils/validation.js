// ==============================================
// VALIDATION UTILITIES
// ==============================================

/**
 * Validate required fields in request body
 * @param {Object} body - Request body
 * @param {Array} requiredFields - Required field names
 * @returns {Object|null} - Error object or null if valid
 */
const validateRequiredFields = (body, requiredFields) => {
  const missingFields = requiredFields.filter(field => {
    const value = body[field];
    return value === undefined || value === null || value === '';
  });

  if (missingFields.length > 0) {
    return {
      valid: false,
      error: `Champs obligatoires manquants: ${missingFields.join(', ')}`,
      missingFields,
    };
  }

  return { valid: true };
};

/**
 * Validate enum values
 * @param {string} value - Value to validate
 * @param {Array} validValues - Array of valid values
 * @returns {boolean}
 */
const validateEnum = (value, validValues) => {
  return validValues.includes(value);
};

/**
 * Validate numeric range
 * @param {number} value - Value to validate
 * @param {number} min - Minimum value
 * @param {number} max - Maximum value
 * @returns {boolean}
 */
const validateRange = (value, min, max) => {
  return value >= min && value <= max;
};

/**
 * Validate email format
 * @param {string} email - Email to validate
 * @returns {boolean}
 */
const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

/**
 * Sanitize user input to prevent injection
 * @param {string} input - User input
 * @returns {string}
 */
const sanitizeInput = (input) => {
  if (typeof input !== 'string') return input;
  return input.trim().replace(/['\";<>]/g, '');
};

/**
 * Export batch validation
 */
const VALIDATION_RULES = {
  statuses: {
    export: ['pending', 'in_progress', 'completed', 'cancelled'],
    import: ['pending', 'in_progress', 'completed', 'cancelled'],
    partnerExport: ['created', 'submitted', 'approved', 'rejected', 'completed'],
  },
  approvalStatuses: ['pending', 'approved', 'rejected'],
  userTypes: ['admin', 'Agent Export', 'Agent Import', 'Partenaire'],
};

module.exports = {
  validateRequiredFields,
  validateEnum,
  validateRange,
  validateEmail,
  sanitizeInput,
  VALIDATION_RULES,
};
