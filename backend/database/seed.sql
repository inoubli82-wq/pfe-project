-- ===========================================
-- SEED DATA - Initial Test Users
-- Run after schema.sql
-- ===========================================

-- Note: Passwords are hashed with bcrypt
-- Plain text passwords for reference:
-- admin@test.com: admin123
-- export@test.com: export123
-- import@test.com: import123
-- partenaire@test.com: partenaire123

-- Clear existing data (optional - remove in production)
TRUNCATE TABLE imports CASCADE;
TRUNCATE TABLE exports CASCADE;
TRUNCATE TABLE users CASCADE;

-- Reset sequences
ALTER SEQUENCE users_id_seq RESTART WITH 1;
ALTER SEQUENCE exports_id_seq RESTART WITH 1;
ALTER SEQUENCE imports_id_seq RESTART WITH 1;

-- ===========================================
-- INSERT TEST USERS
-- Passwords will be hashed by the init script
-- ===========================================
INSERT INTO users (full_name, email, phone, country_code, user_type, transporter, password, status)
VALUES 
    ('Admin Principal', 'admin@test.com', '12345678', '+216', 'admin', NULL, 'HASH_PLACEHOLDER_admin123', 'active'),
    ('Agent Export Test', 'export@test.com', '98765432', '+216', 'Agent Export', NULL, 'HASH_PLACEHOLDER_export123', 'active'),
    ('Agent Import Test', 'import@test.com', '55555555', '+216', 'Agent Import', NULL, 'HASH_PLACEHOLDER_import123', 'active'),
    ('Partenaire DHL', 'partenaire@test.com', '55555522', '+216', 'Partenaire', 'DHL', 'HASH_PLACEHOLDER_partenaire123', 'active'),
    ('Partenaire AST', 'ast@test.com', '55555523', '+216', 'Partenaire', 'AST', 'HASH_PLACEHOLDER_partenaire123', 'active'),
    ('Partenaire TRANSUNIVERS', 'transunivers@test.com', '55555524', '+216', 'Partenaire', 'TRANSUNIVERS', 'HASH_PLACEHOLDER_partenaire123', 'active');

-- ===========================================
-- INSERT SAMPLE EXPORTS
-- ===========================================
INSERT INTO exports (trailer_number, export_date, client_name, country, transporter, bars_count, singles_count, status, created_by)
VALUES 
    ('TR-2024-001', '2024-02-01', 'Client France SA', '🇫🇷 France', 'TRANSUNIVERS', 50, 100, 'completed', 2),
    ('TR-2024-002', '2024-02-05', 'Spain Import Co', '🇪🇸 Espagne', 'DHL', 30, 75, 'in_progress', 2),
    ('TR-2024-003', '2024-02-10', 'German Logistics', '🇩🇪 Allemagne', 'AST', 45, 120, 'pending', 1);

-- ===========================================
-- INSERT SAMPLE IMPORTS
-- ===========================================
INSERT INTO imports (trailer_number, import_date, supplier_name, country, transporter, items_count, status, created_by)
VALUES 
    ('IMP-2024-001', '2024-02-02', 'China Supplier Ltd', '🇨🇳 Chine', 'MSC', 500, 'completed', 3),
    ('IMP-2024-002', '2024-02-08', 'Turkey Materials', '🇹🇷 Turquie', 'Maersk', 300, 'in_progress', 3),
    ('IMP-2024-003', '2024-02-15', 'India Exports', '🇮🇳 Inde', 'CMA CGM', 450, 'pending', 1);

-- =================--
-- SUCCESS MESSAGE  --
-- =================--
SELECT 'Seed data inserted successfully!' AS message;
SELECT 'Users: ' || COUNT(*) FROM users;
SELECT 'Exports: ' || COUNT(*) FROM exports;
SELECT 'Imports: ' || COUNT(*) FROM imports;
