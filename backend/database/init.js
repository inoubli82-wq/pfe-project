// ===========================================
// DATABASE INITIALIZATION SCRIPT
// Run this to create tables and seed data
// ===========================================

const { pool, query } = require("../config/database");
const bcrypt = require("bcryptjs");
const fs = require("fs");
const path = require("path");

const SALT_ROUNDS = 10;

// Test users with plain passwords
const testUsers = [
  {
    full_name: "Admin Principal",
    email: "admin@test.com",
    phone: "12345678",
    country_code: "+216",
    user_type: "admin",
    password: "admin123",
    status: "active",
  },
  {
    full_name: "Agent Export Test",
    email: "export@test.com",
    phone: "98765432",
    country_code: "+216",
    user_type: "Agent Export",
    password: "export123",
    status: "active",
  },
  {
    full_name: "Agent Import Test",
    email: "import@test.com",
    phone: "55555555",
    country_code: "+216",
    user_type: "Agent Import",
    password: "import123",
    status: "active",
  },
  {
    full_name: "partenaire Principal",
    email: "partenaire@test.com",
    phone: "71001110",
    country_code: "+216",
    user_type: "Partenaire",
    password: "partenaire123",
    status: "active",
  },
];

async function initDatabase() {
  console.log("=".repeat(60));
  console.log("🚀 INITIALIZING DATABASE");
  console.log("=".repeat(60));

  try {
    // Test connection
    console.log("\n📡 Testing database connection...");
    await pool.query("SELECT NOW()");
    console.log("✅ Database connection successful!\n");

    // Create tables
    console.log("📋 Creating tables...");
    await createTables();
    console.log("✅ Tables created!\n");

    // Seed users with hashed passwords
    console.log("👥 Seeding users with hashed passwords...");
    await seedUsers();
    console.log("✅ Users seeded!\n");

    // Seed sample data
    console.log("📦 Seeding sample exports and imports...");
    await seedSampleData();
    console.log("✅ Sample data seeded!\n");

    // Display summary
    await displaySummary();

    console.log("=".repeat(60));
    console.log("🎉 DATABASE INITIALIZATION COMPLETE!");
    console.log("=".repeat(60));
  } catch (error) {
    console.error("❌ Initialization failed:", error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

async function createTables() {
  // Users table
  await query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      full_name VARCHAR(255) NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      phone VARCHAR(50),
      country_code VARCHAR(10) DEFAULT '+216',
      user_type VARCHAR(50) NOT NULL,
      password VARCHAR(255) NOT NULL,
      status VARCHAR(20) DEFAULT 'active',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Update user_type constraint to include Partenaire
  try {
    await query(
      `ALTER TABLE users DROP CONSTRAINT IF EXISTS users_user_type_check`,
    );
    await query(
      `ALTER TABLE users ADD CONSTRAINT users_user_type_check CHECK (user_type IN ('admin', 'Agent Export', 'Agent Import', 'Partenaire'))`,
    );
    console.log("   ✅ Updated user_type constraint to include Partenaire");
  } catch (e) {
    console.log("   ⚠️  user_type constraint update skipped");
  }

  // Add transporter column to users table for Partenaire
  try {
    await query(
      `ALTER TABLE users ADD COLUMN IF NOT EXISTS transporter VARCHAR(100)`,
    );
    console.log("   ✅ Added transporter column to users table");
  } catch (e) {
    console.log("   ⚠️  transporter column already exists or skipped");
  }

  // Exports table
  await query(`
    CREATE TABLE IF NOT EXISTS exports (
      id SERIAL PRIMARY KEY,
      trailer_number VARCHAR(100) NOT NULL,
      export_date DATE NOT NULL,
      client_name VARCHAR(255) NOT NULL,
      country VARCHAR(255) NOT NULL,
      transporter VARCHAR(255),
      bars_count INTEGER DEFAULT 0,
      singles_count INTEGER DEFAULT 0,
      status VARCHAR(50) DEFAULT 'pending',
      notes TEXT,
      created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Imports table
  await query(`
    CREATE TABLE IF NOT EXISTS imports (
      id SERIAL PRIMARY KEY,
      trailer_number VARCHAR(100) NOT NULL,
      import_date DATE NOT NULL,
      supplier_name VARCHAR(255) NOT NULL,
      country VARCHAR(255) NOT NULL,
      transporter VARCHAR(255),
      items_count INTEGER DEFAULT 0,
      status VARCHAR(50) DEFAULT 'pending',
      notes TEXT,
      created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Notifications table
  await query(`
    CREATE TABLE IF NOT EXISTS notifications (
      id SERIAL PRIMARY KEY,
      type VARCHAR(50) NOT NULL,
      title VARCHAR(255) NOT NULL,
      message TEXT NOT NULL,
      reference_type VARCHAR(50),
      reference_id INTEGER,
      sender_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
      recipient_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
      is_read BOOLEAN DEFAULT FALSE,
      action_required BOOLEAN DEFAULT FALSE,
      action_taken VARCHAR(50),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      read_at TIMESTAMP
    )
  `);

  // Partenaire Export Data Table
  await query(`
    CREATE TABLE IF NOT EXISTS partenaire_export_data (
      id SERIAL PRIMARY KEY,
      trailer_number VARCHAR(100) NOT NULL,
      embarkation_date DATE NOT NULL,
      client_name VARCHAR(255) NOT NULL,
      number_of_bars INTEGER DEFAULT 0,
      number_of_straps INTEGER DEFAULT 0,
      number_of_suction_cups INTEGER DEFAULT 0,
      status VARCHAR(50) DEFAULT 'created' CHECK (status IN ('created', 'submitted', 'approved', 'rejected', 'completed')),
      approval_status VARCHAR(50) DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected')),
      notes TEXT,
      created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
      approved_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
      approved_at TIMESTAMP,
      rejection_reason TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Add missing columns to existing tables (migrations)
  console.log("   🔄 Running migrations for approval workflow...");

  // Add approval columns to exports if they don't exist
  await safeAddColumn(
    "exports",
    "approval_status",
    "VARCHAR(50) DEFAULT 'pending'",
  );
  await safeAddColumn(
    "exports",
    "approved_by",
    "INTEGER REFERENCES users(id) ON DELETE SET NULL",
  );
  await safeAddColumn("exports", "approved_at", "TIMESTAMP");
  await safeAddColumn("exports", "rejection_reason", "TEXT");

  // Add approval columns to imports if they don't exist
  await safeAddColumn(
    "imports",
    "approval_status",
    "VARCHAR(50) DEFAULT 'pending'",
  );
  await safeAddColumn(
    "imports",
    "approved_by",
    "INTEGER REFERENCES users(id) ON DELETE SET NULL",
  );
  await safeAddColumn("imports", "approved_at", "TIMESTAMP");
  await safeAddColumn("imports", "rejection_reason", "TEXT");

  // Create indexes
  await query(`CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)`);
  await query(
    `CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type)`,
  );
  await query(
    `CREATE INDEX IF NOT EXISTS idx_exports_status ON exports(status)`,
  );
  await query(
    `CREATE INDEX IF NOT EXISTS idx_imports_status ON imports(status)`,
  );
  await query(
    `CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON notifications(recipient_id)`,
  );
  await query(
    `CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read)`,
  );

  // Partenaire export data indexes
  await query(
    `CREATE INDEX IF NOT EXISTS idx_partenaire_export_trailer ON partenaire_export_data(trailer_number)`,
  );
  await query(
    `CREATE INDEX IF NOT EXISTS idx_partenaire_export_status ON partenaire_export_data(status)`,
  );
  await query(
    `CREATE INDEX IF NOT EXISTS idx_partenaire_export_created_by ON partenaire_export_data(created_by)`,
  );

  // Try to create approval indexes (may fail if columns don't exist yet)
  try {
    await query(
      `CREATE INDEX IF NOT EXISTS idx_exports_approval_status ON exports(approval_status)`,
    );
    await query(
      `CREATE INDEX IF NOT EXISTS idx_exports_created_by ON exports(created_by)`,
    );
    await query(
      `CREATE INDEX IF NOT EXISTS idx_imports_approval_status ON imports(approval_status)`,
    );
    await query(
      `CREATE INDEX IF NOT EXISTS idx_imports_created_by ON imports(created_by)`,
    );
    await query(
      `CREATE INDEX IF NOT EXISTS idx_notifications_reference ON notifications(reference_type, reference_id)`,
    );
  } catch (e) {
    console.log("   ⚠️  Some indexes already exist or couldn't be created");
  }
}

// Helper function to safely add a column if it doesn't exist
async function safeAddColumn(table, column, definition) {
  try {
    const checkColumn = await query(
      `
      SELECT column_name FROM information_schema.columns 
      WHERE table_name = $1 AND column_name = $2
    `,
      [table, column],
    );

    if (checkColumn.rows.length === 0) {
      await query(`ALTER TABLE ${table} ADD COLUMN ${column} ${definition}`);
      console.log(`   ✅ Added column ${table}.${column}`);
    }
  } catch (e) {
    console.log(`   ⚠️  Column ${table}.${column} might already exist`);
  }
}

async function seedUsers() {
  for (const user of testUsers) {
    // Check if user exists
    const existing = await query("SELECT id FROM users WHERE email = $1", [
      user.email,
    ]);

    if (existing.rows.length > 0) {
      console.log(`   ⏭️  User ${user.email} already exists, skipping...`);
      continue;
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(user.password, SALT_ROUNDS);

    // Insert user
    await query(
      `INSERT INTO users (full_name, email, phone, country_code, user_type, password, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [
        user.full_name,
        user.email,
        user.phone,
        user.country_code,
        user.user_type,
        hashedPassword,
        user.status,
      ],
    );

    console.log(`   ✅ Created user: ${user.email} (${user.user_type})`);
  }
}

async function seedSampleData() {
  // Get user IDs
  const adminUser = await query(
    "SELECT id FROM users WHERE user_type = 'admin' LIMIT 1",
  );
  const exportUser = await query(
    "SELECT id FROM users WHERE user_type = 'Agent Export' LIMIT 1",
  );
  const importUser = await query(
    "SELECT id FROM users WHERE user_type = 'Agent Import' LIMIT 1",
  );
  const partenaireUser = await query(
    "SELECT id FROM users WHERE user_type = 'Partenaire' LIMIT 1",
  );

  const adminId = adminUser.rows[0]?.id || 1;
  const exportId = exportUser.rows[0]?.id || 2;
  const importId = importUser.rows[0]?.id || 3;
  const partenaireId = partenaireUser.rows[0]?.id || 4;

  // Check if sample data exists
  const existingExports = await query("SELECT COUNT(*) FROM exports");
  if (parseInt(existingExports.rows[0].count) === 0) {
    // Insert sample exports
    await query(
      `INSERT INTO exports (trailer_number, export_date, client_name, country, transporter, bars_count, singles_count, status, created_by)
       VALUES 
         ('TR-2024-001', '2024-02-01', 'Client France SA', '🇫🇷 France', 'Trasuniverse', 50, 100, 'completed', $1),
         ('TR-2024-002', '2024-02-05', 'Spain Import Co', '🇪🇸 Espagne', 'DHL', 30, 75, 'in_progress', $2),
         ('TR-2024-003', '2024-02-10', 'German Logistics', '🇩🇪 Allemagne', 'AST', 45, 120, 'pending', $3)`,
      [exportId, exportId, adminId],
    );
    console.log("   ✅ Sample exports created");
  }

  const existingImports = await query("SELECT COUNT(*) FROM imports");
  if (parseInt(existingImports.rows[0].count) === 0) {
    // Insert sample imports
    await query(
      `INSERT INTO imports (trailer_number, import_date, supplier_name, country, transporter, items_count, status, created_by)
       VALUES 
         ('IMP-2024-001', '2024-02-02', 'China Supplier Ltd', '🇨🇳 Chine', 'MSC', 500, 'completed', $1),
         ('IMP-2024-002', '2024-02-08', 'Turkey Materials', '🇹🇷 Turquie', 'Maersk', 300, 'in_progress', $2),
         ('IMP-2024-003', '2024-02-15', 'India Exports', '🇮🇳 Inde', 'CMA CGM', 450, 'pending', $3)`,
      [importId, importId, adminId],
    );
    console.log("   ✅ Sample imports created");
  }
}

async function displaySummary() {
  const usersCount = await query("SELECT COUNT(*) FROM users");
  const exportsCount = await query("SELECT COUNT(*) FROM exports");
  const importsCount = await query("SELECT COUNT(*) FROM imports");
  const notificationsCount = await query("SELECT COUNT(*) FROM notifications");

  console.log("\n📊 DATABASE SUMMARY:");
  console.log(`   👥 Users: ${usersCount.rows[0].count}`);
  console.log(`   📤 Exports: ${exportsCount.rows[0].count}`);
  console.log(`   📥 Imports: ${importsCount.rows[0].count}`);
  console.log(`   🔔 Notifications: ${notificationsCount.rows[0].count}`);

  console.log("\n🔑 TEST ACCOUNTS:");
  console.log("   🔴 Admin:        admin@test.com / admin123");
  console.log("   🟢 Agent Export: export@test.com / export123");
  console.log("   🔵 Agent Import: import@test.com / import123");
  console.log("   🟣 Partenaire:   partenaire@test.com / partenaire123");
}

// Run initialization
initDatabase();
