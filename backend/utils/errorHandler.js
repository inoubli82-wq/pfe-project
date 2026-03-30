// ==============================================
// ERROR HANDLING UTILITIES
// ==============================================

/**
 * Standard error response format
 * @param {number} statusCode - HTTP status code
 * @param {string} message - Error message
 * @param {*} details - Additional error details
 * @returns {Object}
 */
const createErrorResponse = (statusCode, message, details = null) => {
  const response = {
    success: false,
    message,
  };

  if (details) {
    response.details = details;
  }

  return { statusCode, body: response };
};

/**
 * Standard success response format
 * @param {*} data - Response data
 * @param {string} message - Success message
 * @param {number} statusCode - HTTP status code (default 200)
 * @returns {Object}
 */
const createSuccessResponse = (data, message = 'Succès', statusCode = 200) => {
  const response = {
    success: true,
    message,
  };

  if (data !== null && data !== undefined) {
    response.data = data;
  }

  return { statusCode, body: response };
};

/**
 * Handle database errors with logging
 * @param {Error} error - Database error
 * @param {string} operation - Operation name for logging
 * @returns {Object}
 */
const handleDatabaseError = (error, operation) => {
  console.error(`❌ Erreur DB (${operation}):`, error);

  // Check for specific error types
  if (error.code === '23505') {
    // Unique constraint violation
    return createErrorResponse(409, 'Cette ressource existe déjà');
  }

  if (error.code === '23503') {
    // Foreign key violation
    return createErrorResponse(400, 'Référence invalide');
  }

  // Generic database error
  return createErrorResponse(500, 'Erreur base de données', error.message);
};

/**
 * Handle validation errors
 * @param {Object} validationResult - Result from validateRequiredFields
 * @param {string} context - Context for logging
 * @returns {Object}
 */
const handleValidationError = (validationResult, context = 'Validation') => {
  console.warn(`⚠️ ${context}:`, validationResult.error);
  return createErrorResponse(400, validationResult.error, validationResult);
};

/**
 * Handle authorization errors
 * @param {string} reason - Why authorization failed
 * @returns {Object}
 */
const handleAuthorizationError = (reason = 'Non autorisé') => {
  return createErrorResponse(403, reason);
};

/**
 * Handle not found errors
 * @param {string} resource - Resource name
 * @returns {Object}
 */
const handleNotFoundError = (resource = 'Ressource') => {
  return createErrorResponse(404, `${resource} non trouvé(e)`);
};

/**
 * Handle generic server errors
 * @param {Error} error - Error object
 * @param {string} operation - Operation name
 * @returns {Object}
 */
const handleServerError = (error, operation = 'Opération') => {
  console.error(`❌ Erreur serveur (${operation}):`, error);
  return createErrorResponse(500, 'Erreur serveur interne');
};

/**
 * Wrap async controller methods with error handling
 * @param {Function} fn - Async controller function
 * @returns {Function}
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = {
  createErrorResponse,
  createSuccessResponse,
  handleDatabaseError,
  handleValidationError,
  handleAuthorizationError,
  handleNotFoundError,
  handleServerError,
  asyncHandler,
};
