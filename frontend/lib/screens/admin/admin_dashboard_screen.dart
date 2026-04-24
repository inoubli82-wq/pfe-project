import 'package:flutter/material.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/screens/common/login_screen.dart';
import 'package:import_export_app/screens/common/notifications_screen.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/widgets.dart';
import 'package:intl/intl.dart';

import 'user_management_screen.dart';
import 'role_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final User user;

  const AdminDashboardScreen({super.key, required this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _unreadCount = 0;
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  DateTimeRange? _selectedDateRange;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _loadData();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    String? startStr;
    String? endStr;
    
    if (_selectedDateRange != null) {
      startStr = DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start);
      endStr = DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end);
    }

    await Future.wait([
      _loadUnreadCount(),
      _loadDashboardStats(startStr, endStr),
    ]);

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _loadUnreadCount() async {
    try {
      final response = await ApiService.getUnreadCount();
      if (response['success'] == true && mounted) {
        setState(() => _unreadCount = response['unreadCount'] ?? 0);
      }
    } catch (error) {
      debugPrint('Error loading unread count: $error');
    }
  }

  Future<void> _loadDashboardStats(String? start, String? end) async {
    try {
      final response = await ApiService.getDashboardStats(startDate: start, endDate: end);
      if (response['success'] == true && response['stats'] != null && mounted) {
        setState(() => _stats = Map<String, dynamic>.from(response['stats']));
      }
    } catch (error) {
      debugPrint('Error loading stats: $error');
    }
  }

  void _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3B70),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E3B70),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadData();
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
    });
    _loadData();
  }

  // Helper getters
  int get _barsEnCours => _stats['bars']?['enCours'] ?? 0;
  int get _barsConfirmed => _stats['bars']?['confirmed'] ?? 0;
  int get _barsTunisia => _stats['bars']?['tunisia'] ?? 0;
  List<dynamic> get _stocks => _stats['stocks'] ?? [];

  Widget _buildOverviewTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3B70)));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDateRangeSelector(),
                  const SizedBox(height: 24),
                  _buildMainKPIs(),
                  const SizedBox(height: 32),
                  const Text(
                    'État des Stocks par Société',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3B70),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStocksList(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, ${widget.user.fullName.split(' ')[0]} 👋',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3B70),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Vue d\'ensemble des opérations',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButtonWithBadge(
                  icon: Icons.notifications_none_rounded,
                  badgeCount: _unreadCount,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsScreen(user: widget.user),
                      ),
                    ).then((_) => _loadUnreadCount());
                  },
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _logout,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final hasDate = _selectedDateRange != null;
    final dateText = hasDate
        ? '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'
        : 'Sélectionner une période';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _selectDateRange,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3B70).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF1E3B70)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Période d\'analyse',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: hasDate ? FontWeight.bold : FontWeight.w500,
                              color: hasDate ? const Color(0xFF1E3B70) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasDate)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: _clearDateRange,
                      )
                    else
                      const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainKPIs() {
    return Column(
      children: [
        _buildLargeKpiCard(
          title: 'Total des Barres en Tunisie',
          value: _barsTunisia.toString(),
          icon: Icons.flag_rounded,
          color: const Color(0xFF0D9488),
          gradient: const [Color(0xFF0D9488), Color(0xFF14B8A6)],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmallKpiCard(
                title: 'En Cours\n(Export/Import)',
                value: _barsEnCours.toString(),
                icon: Icons.local_shipping_rounded,
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSmallKpiCard(
                title: 'Confirmés\n(Chez Transporteur)',
                value: _barsConfirmed.toString(),
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStocksList() {
    if (_stocks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Aucune donnée de stock disponible.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: _stocks.map((stock) {
          final transporter = stock['transporter'] ?? 'Inconnu';
          final singles = stock['singles_count'] ?? 0;
          final suctions = stock['suction_cups_count'] ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3B70).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        transporter.toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF1E3B70),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transporter,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3B70),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStockBadge('Barres Simples: $singles', Colors.blue),
                            const SizedBox(width: 8),
                            _buildStockBadge('Ventouses: $suctions', Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStockBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color.withOpacity(0.8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildOverviewTab(),
            const UserManagementScreen(),
            const RoleManagementScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E3B70),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              activeIcon: Icon(Icons.dashboard_rounded, size: 28),
              label: 'Vue globale',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              activeIcon: Icon(Icons.people_alt_rounded, size: 28),
              label: 'Utilisateurs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_rounded),
              activeIcon: Icon(Icons.admin_panel_settings_rounded, size: 28),
              label: 'Rôles',
            ),
          ],
        ),
      ),
    );
  }
}
