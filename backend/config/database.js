// ===========================================
// DATABASE CONFIGURATION - PostgreSQL
// ===========================================

const { Pool } = require("pg");
require("dotenv").config();

// Create connection pool
const pool = new Pool({
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || "pfe_import_export",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "password",
  max: 20, // Maximum number of connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test connection
pool.on("connect", () => {
  console.log("✅ Connected to PostgreSQL database");
});

pool.on("error", (err) => {
  console.error("❌ PostgreSQL connection error:", err);
});

// Query helper function
const query = async (text, params) => {
  const start = Date.now();
  try {
    const result = await pool.query(text, params);
    const duration = Date.now() - start;
    console.log(`📊 Query executed in ${duration}ms`);
    return result;
  } catch (error) {
    console.error("❌ Query error:", error.message);
    throw error;
  }
};

// Get single row
const getOne = async (text, params) => {
  const result = await query(text, params);
  return result.rows[0];
};

// Get multiple rows
const getMany = async (text, params) => {
  const result = await query(text, params);
  return result.rows;
};

module.exports = {
  pool,
  query,
  getOne,
  getMany,
};
