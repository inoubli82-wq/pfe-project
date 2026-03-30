-- ===========================================
-- DATABASE SCHEMA - PostgreSQL
-- Run this script to create tables
-- ===========================================

-- Create database (run this separately if needed)
-- CREATE DATABASE pfe_import_export;

-- Connect to database
-- \c pfe_import_export

-- ===========================================
-- USERS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    country_code VARCHAR(10) DEFAULT '+216',
    user_type VARCHAR(50) NOT NULL CHECK (user_type IN ('admin', 'Agent Export', 'Agent Import', 'Partenaire')),
    transporter VARCHAR(100),
    password VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- EXPORTS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS exports (
    id SERIAL PRIMARY KEY,
    trailer_number VARCHAR(100) NOT NULL,
    export_date DATE NOT NULL,
    client_name VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    transporter VARCHAR(255),
    bars_count INTEGER DEFAULT 0,
    singles_count INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    approval_status VARCHAR(50) DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected')),
    approved_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    notes TEXT,
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- IMPORTS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS imports (
    id SERIAL PRIMARY KEY,
    trailer_number VARCHAR(100) NOT NULL,
    import_date DATE NOT NULL,
    supplier_name VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    transporter VARCHAR(255),
    items_count INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    approval_status VARCHAR(50) DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected')),
    approved_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    notes TEXT,
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- NOTIFICATIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50) NOT NULL CHECK (type IN ('export_request', 'import_request', 'approval', 'rejection', 'info')),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    reference_type VARCHAR(50) CHECK (reference_type IN ('export', 'import')),
    reference_id INTEGER,
    sender_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    recipient_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT FALSE,
    action_required BOOLEAN DEFAULT FALSE,
    action_taken VARCHAR(50) CHECK (action_taken IN ('approved', 'rejected', NULL)),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
);

-- ===========================================
-- INDEXES FOR BETTER PERFORMANCE
-- ===========================================
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
CREATE INDEX IF NOT EXISTS idx_exports_status ON exports(status);
CREATE INDEX IF NOT EXISTS idx_exports_approval_status ON exports(approval_status);
CREATE INDEX IF NOT EXISTS idx_exports_created_by ON exports(created_by);
CREATE INDEX IF NOT EXISTS idx_imports_status ON imports(status);
CREATE INDEX IF NOT EXISTS idx_imports_approval_status ON imports(approval_status);
CREATE INDEX IF NOT EXISTS idx_imports_created_by ON imports(created_by);
CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON notifications(recipient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_reference ON notifications(reference_type, reference_id);

-- ===========================================
-- PARTENAIRE EXPORT DATA TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS partenaire_export_data (
    id SERIAL PRIMARY KEY,
    trailer_number VARCHAR(100) NOT NULL,
    embarkation_date DATE NOT NULL,
    client_name VARCHAR(255) NOT NULL,
    number_of_bars INTEGER DEFAULT 0,
    number_of_straps INTEGER DEFAULT 0,
    number_of_suction_cups INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'created' CHECK (status IN ('created', 'submitted', 'approved', 'rejected', 'completed')),
    notes TEXT,
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for partenaire export data
CREATE INDEX IF NOT EXISTS idx_partenaire_export_trailer ON partenaire_export_data(trailer_number);
CREATE INDEX IF NOT EXISTS idx_partenaire_export_status ON partenaire_export_data(status);
CREATE INDEX IF NOT EXISTS idx_partenaire_export_created_by ON partenaire_export_data(created_by);

-- ===========================================
-- FUNCTION TO UPDATE updated_at TIMESTAMP
-- ===========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ===========================================
-- TRIGGERS FOR AUTO-UPDATE
-- ===========================================
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_exports_updated_at ON exports;
CREATE TRIGGER update_exports_updated_at
    BEFORE UPDATE ON exports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_imports_updated_at ON imports;
CREATE TRIGGER update_imports_updated_at
    BEFORE UPDATE ON imports
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_partenaire_export_updated_at ON partenaire_export_data;
CREATE TRIGGER update_partenaire_export_updated_at
    BEFORE UPDATE ON partenaire_export_data
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ===========================================
-- SUCCESS MESSAGE
-- ===========================================
SELECT 'Schema created successfully!' AS message;
