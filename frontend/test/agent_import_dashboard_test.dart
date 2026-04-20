import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/screens/agent_import/import_dashboard_screen.dart';

void main() {
  group('ImportDashboardScreen Widget Tests', () {
    final mockUser = User(
      id: 3,
      fullName: 'Agent Import',
      email: 'import@test.com',
      phone: '+123',
      role: UserRole.agentImport,
      createdAt: DateTime.now(),
    );

    Widget buildTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ImportDashboardScreen(user: mockUser),
        ),
      );
    }

    testWidgets('should render ImportDashboardScreen', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(ImportDashboardScreen), findsOneWidget);
    });
  });
}
