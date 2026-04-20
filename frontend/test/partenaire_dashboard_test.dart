import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/screens/partenaire/partenaire_dashboard_screen.dart';

void main() {
  group('PartenaireDashboardScreen Widget Tests', () {
    final mockUser = User(
      id: 4,
      fullName: 'Partner',
      email: 'partner@test.com',
      phone: '+123',
      role: UserRole.partenaire,
      createdAt: DateTime.now(),
    );

    Widget buildTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: PartenaireDashboardScreen(user: mockUser),
        ),
      );
    }

    testWidgets('should render PartenaireDashboardScreen', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(PartenaireDashboardScreen), findsOneWidget);
    });
  });
}
