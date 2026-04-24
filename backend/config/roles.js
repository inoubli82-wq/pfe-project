// ==============================================
// ROLES CONFIGURATION
// ==============================================

const ROLES = {
  ADMIN: "admin",
  AGENT_EXPORT: "Agent Export",
  AGENT_IMPORT: "Agent Import",
  AGENT_STOCK: "Agent de Stock",
  PARTENAIRE: "Partenaire",
};

// Valid transporters for Partenaire users
const VALID_TRANSPORTERS = ["DHL", "AST", "TRANSUNIVERS"];

// Role permissions
const PERMISSIONS = {
  [ROLES.ADMIN]: ["read", "write", "delete", "manage_users", "view_all"],
  [ROLES.AGENT_EXPORT]: ["read", "write", "create_export"],
  [ROLES.AGENT_IMPORT]: ["read", "write", "create_import"],
  [ROLES.AGENT_STOCK]: ["read", "write", "manage_stock"],
  [ROLES.PARTENAIRE]: ["read", "approve", "reject", "view_requests"],
};

module.exports = { ROLES, PERMISSIONS, VALID_TRANSPORTERS };
