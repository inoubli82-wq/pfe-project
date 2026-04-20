import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/screens/agent_export/export_dashboard_screen.dart';

void main() {
  group('ExportDashboardScreen Widget Tests', () {
    final mockUser = User(
      id: 2,
      fullName: 'Agent Export',
      email: 'export@test.com',
      phone: '+123',
      role: UserRole.agentExport,
      createdAt: DateTime.now(),
    );

    Widget buildTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ExportDashboardScreen(user: mockUser),
        ),
      );
    }

    testWidgets('should render ExportDashboardScreen', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(ExportDashboardScreen), findsOneWidget);
    });
  });
}
