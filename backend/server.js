require("dotenv").config();
const express = require("express");
const cors = require("cors");

// Import configuration
const { query, getOne } = require("./config/database");
const { ROLES } = require("./config/roles");

// Import routes
const { registerRoutes } = require("./routes");
const { generateToken } = require("./utils/helpers");

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5000;

// ==============================================
// MIDDLEWARE CONFIGURATION
// ==============================================
app.use(cors());
app.use(express.json());

// ==============================================
// ROOT ROUTES (Health check & info)
// ==============================================

// Root endpoint - API info & health check
app.get("/", async (req, res) => {
  try {
    const usersCount = await getOne("SELECT COUNT(*) FROM users");
    const exportsCount = await getOne("SELECT COUNT(*) FROM exports");
    const importsCount = await getOne("SELECT COUNT(*) FROM imports");

    res.json({
      success: true,
      message: "🚀 BACKEND PFE - PostgreSQL + MVC Architecture",
      version: "5.0.0",
      database: "PostgreSQL",
      architecture: "MVC (Controllers/Routes/Middleware)",
      timestamp: new Date().toISOString(),
      stats: {
        users: parseInt(usersCount.count),
        exports: parseInt(exportsCount.count),
        imports: parseInt(importsCount.count),
      },
      roles: Object.values(ROLES),
      endpoints: {
        auth: "/api/auth",
        admin: "/api/admin",
        exports: "/api/exports",
        imports: "/api/imports",
        partenaires: "/api/partenaires",
      },
    });
  } catch (error) {
    res.json({
      success: true,
      message: "🚀 BACKEND PFE - PostgreSQL",
      warning: "Database not initialized. Run: npm run db:init",
    });
  }
});

// Test database connection
app.get("/api/test", async (req, res) => {
  try {
    const result = await query("SELECT NOW() as time");
    res.json({
      success: true,
      message: "✅ PostgreSQL connecté",
      serverTime: result.rows[0].time,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "❌ Erreur de connexion PostgreSQL",
      error: error.message,
    });
  }
});

registerRoutes(app);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route non trouvée: ${req.method} ${req.url}`,
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error("❌ Erreur serveur:", err);
  res.status(500).json({
    success: false,
    message: "Erreur serveur interne",
  });
});

// ==============================================
// START SERVER
// ==============================================
app.listen(PORT, () => {
  console.log(`📡 Port: ${PORT}`);
  console.log(`🌐 URL: http://localhost:${PORT}`);
  console.log(`🗄️  Database: PostgreSQL`);
  console.log("");

  console.log("📋 SETUP:");
  console.log("   1. Create database: createdb pfe_import_export");
  console.log("   2. Initialize: npm run db:init");
  console.log("");
  console.log("🔑 TEST ACCOUNTS (after db:init):");
  console.log("   🔴 Admin:        admin@test.com / admin123");
  console.log("   🟢 Agent Export: export@test.com / export123");
  console.log("   🔵 Agent Import: import@test.com / import123");
  console.log("   🟠 Partenaire DHL:        partenaire@test.com / partenaire123");
  console.log("   🟠 Partenaire AST:        ast@test.com / partenaire123");
  console.log("   🟠 Partenaire TRANSUNIVERS: transunivers@test.com / partenaire123");
  console.log("=".repeat(60));
});
