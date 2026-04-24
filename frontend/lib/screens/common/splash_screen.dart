import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../agent_export/export_dashboard_screen.dart';
import '../agent_import/import_dashboard_screen.dart';
import '../partenaire/partenaire_dashboard_screen.dart';
import '../agent_stock/stock_agent_dashboard.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthAndNavigate();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Minimum splash display time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Listen to auth state changes
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait for auth initialization to complete
    while (!authProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    // Small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Navigate based on auth status
    _navigateBasedOnAuth(authProvider);
  }

  void _navigateBasedOnAuth(AuthProvider authProvider) {
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      // User is authenticated - navigate to dashboard
      _navigateToDashboard(authProvider.currentUser!);
    } else {
      // User is not authenticated - navigate to login
      _navigateToLogin();
    }
  }

  void _navigateToDashboard(User user) {
    Widget dashboard;

    switch (user.role) {
      case UserRole.admin:
        dashboard = AdminDashboardScreen(user: user);
        break;
      case UserRole.agentExport:
        dashboard = ExportDashboardScreen(user: user);
        break;
      case UserRole.agentImport:
        dashboard = ImportDashboardScreen(user: user);
        break;
      case UserRole.partenaire:
        dashboard = PartenaireDashboardScreen(user: user);
        break;
      case UserRole.agentStock:
        dashboard = StockAgentDashboard(user: user);
        break;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => dashboard,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  'assets/images/splash/profile_default.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image fails to load
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_shipping,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
