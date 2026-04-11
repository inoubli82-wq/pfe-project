// ===========================================
// USER MODEL WITH ROLE-BASED ACCESS
// ===========================================

enum UserRole {
  admin,
  agentExport,
  agentImport,
  partenaire,
}

class User {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? transporter;
  final UserRole role;
  final String? token;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.transporter,
    required this.role,
    this.token,
    required this.createdAt,
  });

  // Convert string to UserRole enum
  static UserRole stringToRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'agent export':
      case 'agentexport':
        return UserRole.agentExport;
      case 'agent import':
      case 'agentimport':
        return UserRole.agentImport;
      case 'partenaire':
        return UserRole.partenaire;
      default:
        return UserRole.agentExport; // Default role
    }
  }

  // Convert UserRole enum to display string
  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.agentExport:
        return 'Agent Export';
      case UserRole.agentImport:
        return 'Agent Import';
      case UserRole.partenaire:
        return 'Partenaire';
    }
  }

  // Convert UserRole enum to API string
  static String roleToApiString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.agentExport:
        return 'Agent Export';
      case UserRole.agentImport:
        return 'Agent Import';
      case UserRole.partenaire:
        return 'Partenaire';
    }
  }

  // Create User from JSON
  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      transporter: json['transporter'],
      role: stringToRole(json['userType'] ?? json['role'] ?? 'Agent Export'),
      token: token ?? json['token'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'transporter': transporter,
      'userType': roleToApiString(role),
      'role': roleToApiString(role),
      'token': token,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Check permissions
  bool get isAdmin => role == UserRole.admin;
  bool get isAgentExport => role == UserRole.agentExport;
  bool get isAgentImport => role == UserRole.agentImport;
  bool get isPartenaire => role == UserRole.partenaire;

  String get displayRoleLabel {
    if (isPartenaire && transporter != null && transporter!.isNotEmpty) {
      return '$transporter Partenaire';
    }
    return roleToString(role);
  }

  // Check if user can access certain features
  bool canCreateExport() => isAdmin || isAgentExport;
  bool canCreateImport() => isAdmin || isAgentImport;
  bool canManageUsers() => isAdmin;
  bool canViewReports() => isAdmin;
  bool canViewAllExports() => isAdmin || isAgentExport;
  bool canViewAllImports() => isAdmin || isAgentImport;
  bool canApproveRequests() => isPartenaire;
  bool canViewPendingRequests() => isAdmin || isPartenaire;

  @override
  String toString() {
    return 'User{id: $id, fullName: $fullName, email: $email, role: ${roleToString(role)}}';
  }
}
