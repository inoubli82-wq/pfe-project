import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import 'partner_import_suivi_screen.dart';
import 'partner_suivi_screen.dart';

class PartnerSuiviTabsScreen extends StatelessWidget {
  final User user;

  const PartnerSuiviTabsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Suivi des Opérations',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.download),
                text: 'Mes Imports',
              ),
              Tab(
                icon: Icon(Icons.upload),
                text: 'Mes Exports',
              ),
            ],
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: TabBarView(
          children: [
            // Onglet Suivi Import
            PartnerImportSuiviScreen(user: user),

            // Onglet Suivi Export
            PartnerSuiviScreen(user: user),
          ],
        ),
      ),
    );
  }
}
