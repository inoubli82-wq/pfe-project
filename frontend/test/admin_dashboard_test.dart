import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/screens/admin/admin_dashboard_screen.dart';

void main() {
  group('AdminDashboardScreen Widget Tests', () {
    final mockUser = User(
      id: 1,
      fullName: 'Admin User',
      email: 'admin@test.com',
      phone: '+123456789',
      role: UserRole.admin,
      createdAt: DateTime.now(),
    );

    Widget buildTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: AdminDashboardScreen(user: mockUser),
        ),
      );
    }

    testWidgets('should render AdminDashboardScreen', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(AdminDashboardScreen), findsOneWidget);
    });
  });
}
