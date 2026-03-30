// ==============================================
// ROUTES INDEX - Central route registration
// ==============================================

const authRoutes = require("./authRoutes");
const adminRoutes = require("./adminRoutes");
const exportRoutes = require("./exportRoutes");
const partnerExportRoutes = require("./partnerExportRoutes");
const importRoutes = require("./importRoutes");
const notificationRoutes = require("./notificationRoutes");

/**
 * Register all routes with the Express app
 * @param {Express} app - Express application instance
 */
const registerRoutes = (app) => {
  // Auth routes
  app.use("/api/auth", authRoutes);

  // Admin routes
  app.use("/api/admin", adminRoutes);

  // Export routes
  app.use("/api/exports", exportRoutes);

  // Partner Export routes
  app.use("/api/export-data", partnerExportRoutes);

  // Import routes
  app.use("/api/imports", importRoutes);

  // Notification routes
  app.use("/api/notifications", notificationRoutes);
};

module.exports = { registerRoutes };
