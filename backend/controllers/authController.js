const bcrypt = require("bcryptjs");
const { query, getOne } = require("../config/database");
const { ROLES, VALID_TRANSPORTERS } = require("../config/roles");
const {
  generateToken,
  formatUser,
  extractUserIdFromToken,
} = require("../utils/helpers");

const SALT_ROUNDS = 10;

/**
 * Register a new user
 * POST /api/auth/register
 */
const register = async (req, res) => {
  console.log("📝 Nouvelle inscription:", req.body.email);

  const {
    fullName,
    email,
    phone,
    countryCode,
    userType,
    password,
    confirmPassword,
    transporter,
  } = req.body;

  try {
    // Validation
    if (
      !fullName ||
      !email ||
      !phone ||
      !userType ||
      !password ||
      !confirmPassword
    ) {
      return res.status(400).json({
        success: false,
        message: "Tous les champs sont obligatoires",
      });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: "Format d'email invalide",
      });
    }

    // Check if email exists
    const existingUser = await getOne("SELECT id FROM users WHERE email = $1", [
      email,
    ]);
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: "Un compte existe déjà avec cet email",
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: "Le mot de passe doit contenir au moins 6 caractères",
      });
    }

    if (password !== confirmPassword) {
      return res.status(400).json({
        success: false,
        message: "Les mots de passe ne correspondent pas",
      });
    }

    // Allow Agent Export, Agent Import, and Partenaire for registration
    const validUserTypes = [
      ROLES.AGENT_EXPORT,
      ROLES.AGENT_IMPORT,
      ROLES.PARTENAIRE,
    ];
    if (!validUserTypes.includes(userType)) {
      return res.status(400).json({
        success: false,
        message: "Type d'utilisateur invalide",
      });
    }

    // Validate transporter for Partenaire users
    if (userType === ROLES.PARTENAIRE) {
      if (!transporter) {
        return res.status(400).json({
          success: false,
          message: "Le transporteur est obligatoire pour les partenaires",
        });
      }
      if (!VALID_TRANSPORTERS.includes(transporter)) {
        return res.status(400).json({
          success: false,
          message: `Transporteur invalide. Valeurs autorisées: ${VALID_TRANSPORTERS.join(", ")}`,
        });
      }
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    // Insert user (include transporter for Partenaire)
    const result = await query(
      `INSERT INTO users (full_name, email, phone, country_code, user_type, transporter, password, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'active')
       RETURNING *`,
      [
        fullName,
        email,
        phone,
        countryCode || "+216",
        userType,
        transporter || null,
        hashedPassword,
      ],
    );

    const newUser = result.rows[0];
    const token = generateToken(newUser);

    console.log(`✅ Utilisateur créé: ${email} (${userType})`);

    res.status(201).json({
      success: true,
      message: `✅ Compte ${userType} créé avec succès !`,
      user: formatUser(newUser),
      token,
    });
  } catch (error) {
    console.error("❌ Erreur inscription:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur lors de l'inscription",
    });
  }
};

/**
 * Login user
 * POST /api/auth/login
 */
const login = async (req, res) => {
  console.log("🔐 Tentative de connexion:", req.body.email);

  const { email, password } = req.body;

  try {
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email et mot de passe requis",
      });
    }

    // Find user
    const user = await getOne("SELECT * FROM users WHERE email = $1", [email]);

    if (!user) {
      return res.status(401).json({
        success: false,
        message: "❌ Email ou mot de passe incorrect",
      });
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password);

    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: "❌ Email ou mot de passe incorrect",
      });
    }

    // Check if user is active
    if (user.status !== "active") {
      return res.status(403).json({
        success: false,
        message: "Compte désactivé. Contactez l'administrateur.",
      });
    }

    const token = generateToken(user);

    console.log(`✅ Connexion réussie: ${email} (${user.user_type})`);

    res.json({
      success: true,
      message: `✅ Connexion réussie en tant que ${user.user_type} !`,
      user: formatUser(user),
      token,
    });
  } catch (error) {
    console.error("❌ Erreur connexion:", error);
    res.status(500).json({
      success: false,
      message: "Erreur serveur lors de la connexion",
    });
  }
};

/**
 * Get user profile
 * GET /api/auth/profile
 */
const getProfile = async (req, res) => {
  const token = req.headers.authorization?.replace("Bearer ", "");

  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Token manquant",
    });
  }

  try {
    const userId = extractUserIdFromToken(token);

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "Token invalide",
      });
    }

    const user = await getOne("SELECT * FROM users WHERE id = $1", [userId]);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "Utilisateur non trouvé",
      });
    }

    res.json({
      success: true,
      user: formatUser(user),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

/**
 * Forgot password
 * POST /api/auth/forgot-password
 */
const forgotPassword = async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({
      success: false,
      message: "Email requis",
    });
  }

  try {
    const user = await getOne("SELECT id FROM users WHERE email = $1", [email]);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "Aucun compte trouvé avec cet email",
      });
    }

    // TODO: Send actual email with reset link
    res.json({
      success: true,
      message: "📧 Email de réinitialisation envoyé",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Erreur serveur",
    });
  }
};

module.exports = {
  register,
  login,
  getProfile,
  forgotPassword,
};
