/// ============================================
/// APP STRINGS - Centralized Text Constants
/// ============================================
///
/// Usage: AppStrings.appName, AppStrings.loginTitle, etc.
/// Makes localization easier and prevents typos.
library;

class AppStrings {
  AppStrings._(); // Private constructor

  // ==================== APP INFO ====================
  static const String appName = 'AST Logitrack';
  static const String appNameShort = 'AST';
  static const String appTagline = 'Logitrack';
  static const String companyName = 'AST Logistics';

  // ==================== AUTH SCREENS ====================
  static const String login = 'Connexion';
  static const String register = 'Inscription';
  static const String logout = 'Déconnexion';
  static const String forgotPassword = 'Mot de passe oublié ?';
  static const String resetPassword = 'Réinitialiser le mot de passe';
  static const String email = 'Email';
  static const String password = 'Mot de passe';
  static const String confirmPassword = 'Confirmer le mot de passe';
  static const String fullName = 'Nom complet';
  static const String phone = 'Téléphone';
  static const String rememberMe = 'Se souvenir de moi';
  static const String noAccount = 'Pas encore de compte ?';
  static const String haveAccount = 'Déjà un compte ?';

  // ==================== ROLES ====================
  static const String admin = 'Administrateur';
  static const String agentExport = 'Agent Export';
  static const String agentImport = 'Agent Import';
  static const String partenaire = 'Partenaire';

  // ==================== NAVIGATION ====================
  static const String home = 'Accueil';
  static const String dashboard = 'Tableau de bord';
  static const String profile = 'Profil';
  static const String settings = 'Paramètres';
  static const String notifications = 'Notifications';
  static const String history = 'Historique';

  // ==================== OPERATIONS ====================
  static const String import = 'Import';
  static const String export = 'Export';
  static const String newExport = 'Nouvelle exportation';
  static const String newImport = 'Nouvelle importation';
  static const String commandList = 'Liste des commandes';
  static const String pendingRequests = 'Demandes en attente';

  // ==================== STATUS ====================
  static const String pending = 'En attente';
  static const String inProgress = 'En cours';
  static const String completed = 'Terminé';
  static const String cancelled = 'Annulé';
  static const String approved = 'Approuvé';
  static const String rejected = 'Rejeté';

  // ==================== ACTIONS ====================
  static const String save = 'Enregistrer';
  static const String cancel = 'Annuler';
  static const String confirm = 'Confirmer';
  static const String delete = 'Supprimer';
  static const String edit = 'Modifier';
  static const String send = 'Envoyer';
  static const String search = 'Rechercher';
  static const String filter = 'Filtrer';
  static const String refresh = 'Actualiser';
  static const String retry = 'Réessayer';
  static const String viewAll = 'Voir tout';
  static const String viewDetails = 'Voir détails';
  static const String back = 'Retour';
  static const String next = 'Suivant';
  static const String submit = 'Soumettre';
  static const String approve = 'Approuver';
  static const String reject = 'Rejeter';

  // ==================== FORM LABELS ====================
  static const String trailerNumber = 'N° Remorque';
  static const String transporter = 'Transporteur';
  static const String client = 'Client';
  static const String supplier = 'Fournisseur';
  static const String country = 'Pays';
  static const String date = 'Date';
  static const String comment = 'Commentaire';
  static const String optional = '(optionnel)';
  static const String required = 'Obligatoire';

  // ==================== MESSAGES ====================
  static const String loading = 'Chargement...';
  static const String error = 'Erreur';
  static const String success = 'Succès';
  static const String noData = 'Aucune donnée';
  static const String noResults = 'Aucun résultat';
  static const String networkError = 'Erreur de connexion au serveur';
  static const String unknownError = 'Une erreur est survenue';
  static const String sessionExpired =
      'Session expirée, veuillez vous reconnecter';
  static const String noInternet = 'Pas de connexion internet';

  // ==================== VALIDATION ====================
  static const String fieldRequired = 'Ce champ est obligatoire';
  static const String invalidEmail = 'Email invalide';
  static const String passwordTooShort =
      'Le mot de passe doit contenir au moins 6 caractères';
  static const String passwordMismatch =
      'Les mots de passe ne correspondent pas';
  static const String invalidPhone = 'Numéro de téléphone invalide';

  // ==================== CONFIRMATION ====================
  static const String confirmLogout = 'Voulez-vous vraiment vous déconnecter ?';
  static const String confirmDelete =
      'Voulez-vous vraiment supprimer cet élément ?';
  static const String confirmCancel = 'Voulez-vous vraiment annuler ?';
  static const String unsavedChanges =
      'Vous avez des modifications non enregistrées.';
}
