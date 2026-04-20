import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:import_export_app/screens/common/forgot_password_screen.dart';
import 'package:import_export_app/screens/common/login_screen.dart';
import 'package:import_export_app/screens/common/register_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    Widget buildTestWidget(Widget child) {
      return SizedBox(
        width: 400,
        height: 800,
        child: MaterialApp(home: child),
      );
    }

    testWidgets('should display login form elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const LoginScreen()));

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Créer mon compte'), findsOneWidget);
      expect(find.text("Mot de passe oublié ?"), findsOneWidget);
    });

    testWidgets('should show validation error for empty email',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const LoginScreen()));

      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Veuillez entrer votre email'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid email format',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const LoginScreen()));

      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Email invalide'), findsOneWidget);
    });

    testWidgets('should show validation error for empty password',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const LoginScreen()));

      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);
    });

    testWidgets('should show validation error for short password',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const LoginScreen()));

      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Le mot de passe doit contenir au moins 6 caractères'),
          findsOneWidget);
    });

    testWidgets('should toggle password visibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const LoginScreen()));

      final passwordField = find.byType(TextFormField).last;
      expect(passwordField, findsOneWidget);

      final visibilityButton = find.byIcon(Icons.visibility_off);
      expect(visibilityButton, findsOneWidget);

      await tester.tap(visibilityButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets(
        'should navigate to register screen when clicking create account button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const SizedBox(
          width: 400,
          height: 800,
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Créer mon compte'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('should navigate to forgot password screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const LoginScreen()));

      await tester.tap(find.text("Mot de passe oublié ?"));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });
  });

  group('RegisterScreen Widget Tests', () {
    Widget buildTestWidget(Widget child) {
      return SizedBox(
        width: 400,
        height: 800,
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('should display register form elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const RegisterScreen()));

      // Since it's a scrollable view, we might not see everything immediately,
      // but let's check for some key inputs that are initially rendered.
      expect(find.text("Formulaire d'inscription"), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should perform something when submitted empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const RegisterScreen()));

      // The submit button is "Confirmer" according to the code
      final confirmButton = find.text('Confirmer');
      // Wrap scrollable taps
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Just check we remain on the same screen (it doesn't crash)
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('should navigate back when back button pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const RegisterScreen()));

      final backButton = find.byIcon(Icons.arrow_back_ios);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();
    });
  });

  group('ForgotPasswordScreen Widget Tests', () {
    Widget buildTestWidget(Widget child) {
      return SizedBox(
        width: 400,
        height: 800,
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('should display basic elements', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const ForgotPasswordScreen()));

      expect(find.text('Page de récupération de mot de passe'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should navigate back on back button press',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(const ForgotPasswordScreen()));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });
  });
}
