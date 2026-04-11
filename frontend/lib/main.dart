import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/common/splash_screen.dart';

/// ============================================
/// MAIN ENTRY POINT
/// ============================================

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only for mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _appBackgroundImage =
      'assets/images/backgrounds/login_background.jpg';

  @override
  Widget build(BuildContext context) {
    // Wrap app with MultiProvider for scalability
    return MultiProvider(
      providers: [
        // Auth Provider - manages authentication state
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..init(),
        ),
        // Add more providers here as needed:
        // ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            // App configuration
            title: 'AST Logitrack',
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light, // Can be changed to support dark mode

            // Starting screen
            home: const SplashScreen(),

            // Route builder for transitions
            builder: (context, child) {
              // Apply responsive text scaling
              final mediaQuery = MediaQuery.of(context);
              final scale = mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.2);

              Widget wrappedChild = child!;
              if (child is! SplashScreen) {
                wrappedChild = Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_appBackgroundImage),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Color(0x99000000),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: child,
                );
              }

              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(scale),
                ),
                child: wrappedChild,
              );
            },
          );
        },
      ),
    );
  }
}
