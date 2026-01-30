// ==============================================
// SERVEUR BACKEND PFE IMPORT/EXPORT
// ==============================================
const express = require("express");
const cors = require("cors");
const app = express();
const PORT = 5000;

// ========== CONFIGURATION ==========
app.use(cors());
app.use(express.json());

// ========== BASE DE DONNÉES SIMULÉE ==========
let users = [
  {
    id: 1,
    fullName: "Admin Test",
    email: "admin@test.com",
    phone: "+21612345678",
    countryCode: "+216",
    userType: "Agent Export",
    password: "123456", // En production, utiliser bcrypt
    createdAt: "2024-01-30T10:00:00.000Z"
  }
];

// ========== ROUTES API ==========

// 1. ROUTE RACINE - Vérification serveur
app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "🚀 BACKEND PFE IMPORT/EXPORT - API ACTIVE",
    version: "2.0.0",
    timestamp: new Date().toISOString(),
    endpoints: {
      auth: {
        register: "POST /api/auth/register",
        login: "POST /api/auth/login",
        users: "GET /api/auth/users"
      },
      test: "GET /api/test"
    }
  });
});

// 2. ROUTE TEST
app.get("/api/test", (req, res) => {
  res.json({
    success: true,
    message: "✅ Backend opérationnel",
    server: "Node.js/Express",
    port: PORT,
    totalUsers: users.length
  });
});

// 3. INSCRIPTION - NOUVEAU FORMULAIRE
app.post("/api/auth/register", (req, res) => {
  console.log("📝 Nouvelle inscription reçue:", req.body);
  
  const {
    fullName,
    email,
    phone,
    countryCode,
    userType,
    password,
    confirmPassword
  } = req.body;
  
  // ========== VALIDATION ==========
  
  // 1. Champs obligatoires
  if (!fullName || !email || !phone || !userType || !password || !confirmPassword) {
    return res.status(400).json({
      success: false,
      message: "Tous les champs sont obligatoires"
    });
  }
  
  // 2. Validation email
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({
      success: false,
      message: "Format d'email invalide"
    });
  }
  
  // 3. Vérifier si email existe déjà
  const emailExists = users.some(user => user.email === email);
  if (emailExists) {
    return res.status(400).json({
      success: false,
      message: "Un compte existe déjà avec cet email"
    });
  }
  
  // 4. Vérifier mot de passe
  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      message: "Le mot de passe doit contenir au moins 6 caractères"
    });
  }
  
  // 5. Confirmation mot de passe
  if (password !== confirmPassword) {
    return res.status(400).json({
      success: false,
      message: "Les mots de passe ne correspondent pas"
    });
  }
  
  // 6. Vérifier type d'utilisateur
  const validUserTypes = ["Agent Export", "Agent Import", "Partenaire"];
  if (!validUserTypes.includes(userType)) {
    return res.status(400).json({
      success: false,
      message: "Type d'utilisateur invalide"
    });
  }
  
  // ========== CRÉATION UTILISATEUR ==========
  
  const newUser = {
    id: users.length + 1,
    fullName,
    email,
    phone: countryCode + phone.replace(/\D/g, ''), // Formater le numéro
    countryCode,
    userType,
    password, // À hasher en production avec bcrypt
    createdAt: new Date().toISOString(),
    status: "active"
  };
  
  users.push(newUser);
  
  console.log(`✅ Nouvel utilisateur créé: ${email} (${userType})`);
  
  // ========== RÉPONSE ==========
  
  res.status(201).json({
    success: true,
    message: `✅ Compte ${userType} créé avec succès !`,
    user: {
      id: newUser.id,
      fullName: newUser.fullName,
      email: newUser.email,
      phone: newUser.phone,
      userType: newUser.userType,
      createdAt: newUser.createdAt
    },
    token: `jwt-token-${newUser.id}-${Date.now()}`,
    debug: {
      totalUsers: users.length,
      userType: userType
    }
  });
});

// 4. CONNEXION
app.post("/api/auth/login", (req, res) => {
  console.log("🔐 Tentative de connexion:", req.body.email);
  
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: "Email et mot de passe requis"
    });
  }
  
  // Chercher l'utilisateur
  const user = users.find(u => u.email === email);
  
  if (!user) {
    return res.status(401).json({
      success: false,
      message: "❌ Email ou mot de passe incorrect"
    });
  }
  
  // Vérifier mot de passe (simulé)
  if (user.password !== password) {
    return res.status(401).json({
      success: false,
      message: "❌ Email ou mot de passe incorrect"
    });
  }
  
  // Connexion réussie
  res.json({
    success: true,
    message: "✅ Connexion réussie !",
    user: {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      userType: user.userType,
      createdAt: user.createdAt
    },
    token: `jwt-auth-token-${user.id}-${Date.now()}`
  });
});

// 5. LISTE DES UTILISATEURS (pour debug/admin)
app.get("/api/auth/users", (req, res) => {
  res.json({
    success: true,
    count: users.length,
    users: users.map(u => ({
      id: u.id,
      fullName: u.fullName,
      email: u.email,
      userType: u.userType,
      phone: u.phone,
      createdAt: u.createdAt
    }))
  });
});

// 6. RÉINITIALISATION MOT DE PASSE
app.post("/api/auth/forgot-password", (req, res) => {
  const { email } = req.body;
  
  if (!email) {
    return res.status(400).json({
      success: false,
      message: "Email requis"
    });
  }
  
  const userExists = users.some(u => u.email === email);
  
  if (!userExists) {
    return res.status(404).json({
      success: false,
      message: "Aucun compte trouvé avec cet email"
    });
  }
  
  res.json({
    success: true,
    message: "📧 Email de réinitialisation envoyé (simulation)",
    note: "En production, envoyer un vrai email avec lien de réinitialisation"
  });
});

// 7. ROUTES SUPPLÉMENTAIRES POUR FLUTTER
app.get("/api/auth/profile", (req, res) => {
  // Simulation - normalement vérifier le token JWT
  const token = req.headers.authorization;
  
  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Token manquant"
    });
  }
  
  // Simuler un utilisateur
  res.json({
    success: true,
    user: {
      id: 1,
      fullName: "Utilisateur Test",
      email: "test@example.com",
      userType: "Agent Export",
      phone: "+21612345678"
    }
  });
});

// ========== GESTION ERREURS ==========

// Route non trouvée
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route non trouvée: ${req.method} ${req.url}`,
    availableRoutes: [
      "GET /",
      "GET /api/test",
      "POST /api/auth/register",
      "POST /api/auth/login",
      "GET /api/auth/users",
      "POST /api/auth/forgot-password",
      "GET /api/auth/profile"
    ]
  });
});

// Erreur serveur
app.use((err, req, res, next) => {
  console.error("❌ Erreur serveur:", err);
  
  res.status(500).json({
    success: false,
    message: "Erreur serveur interne",
    error: process.env.NODE_ENV === "development" ? err.message : undefined
  });
});

// ========== DÉMARRAGE SERVEUR ==========
app.listen(PORT, () => {
  console.log("=".repeat(60));
  console.log("🚀 BACKEND PFE DÉMARRÉ AVEC SUCCÈS !");
  console.log("=".repeat(60));
  console.log(`📡 Port: ${PORT}`);
  console.log(`🌐 URL: http://localhost:${PORT}`);
  console.log(`📱 URL émulateur: http://10.0.2.2:${PORT}`);
  console.log("");
  console.log("👤 UTILISATEUR TEST:");
  console.log("   Email: admin@test.com");
  console.log("   Mot de passe: 123456");
  console.log("");
  console.log("📋 ENDPOINTS:");
  console.log(`   GET  http://localhost:${PORT}/`);
  console.log(`   POST http://localhost:${PORT}/api/auth/register`);
  console.log(`   POST http://localhost:${PORT}/api/auth/login`);
  console.log("");
  console.log("⚡ Prêt à recevoir des requêtes...");
  console.log("=".repeat(60));
});