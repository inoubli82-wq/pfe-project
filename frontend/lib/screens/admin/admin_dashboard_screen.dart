import 'dart:math';

import 'package:flutter/material.dart';
import 'package:import_export_app/models/export_data.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/screens/common/login_screen.dart';
import 'package:import_export_app/screens/common/notifications_screen.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/widgets.dart';

enum DashboardPeriod {
  last7Days(7, '7 derniers jours', '7d'),
  last15Days(15, '15 derniers jours', '15d'),
  last30Days(30, '30 derniers jours', '30d');

  const DashboardPeriod(this.days, this.label, this.apiKey);

  final int days;
  final String label;
  final String apiKey;
}

class _ActivityPoint {
  const _ActivityPoint({
    required this.label,
    required this.exports,
    required this.imports,
    required this.pending,
  });

  final String label;
  final int exports;
  final int imports;
  final int pending;
}

class _RecentActivityItem {
  const _RecentActivityItem({
    required this.date,
    required this.client,
    required this.type,
    required this.status,
    required this.statusColor,
  });

  final String date;
  final String client;
  final String type;
  final String status;
  final Color statusColor;
}

class _PieSlice {
  const _PieSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class AdminDashboardScreen extends StatefulWidget {
  final User user;

  const AdminDashboardScreen({super.key, required this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _unreadCount = 0;
  Map<String, dynamic> _stats = {};
  List<ExportData> _allExportData = [];
  bool _isLoading = true;
  DashboardPeriod _selectedPeriod = DashboardPeriod.last7Days;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const List<String> _weekDays = [
    'lun.',
    'mar.',
    'mer.',
    'jeu.',
    'ven.',
    'sam.',
    'dim.',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
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
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = true);
    await Future.wait([
      _loadUnreadCount(),
      _loadDashboardStats(),
      _loadPartnerExportData(),
    ]);
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadUnreadCount() async {
    try {
      final response = await ApiService.getUnreadCount();
      if (response['success'] == true) {
        if (!mounted) {
          return;
        }
        setState(() => _unreadCount = _toInt(response['unreadCount']));
      }
    } catch (error) {
      debugPrint('Error loading unread count: $error');
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final response = await ApiService.getDashboardStats();
      if (response['success'] == true && response['stats'] != null) {
        if (!mounted) {
          return;
        }
        setState(() => _stats = Map<String, dynamic>.from(response['stats']));
      }
    } catch (error) {
      debugPrint('Error loading stats: $error');
    }
  }

  Future<void> _loadPartnerExportData() async {
    try {
      final response = await ApiService.getAllExportData();
      if (response['success'] == true && response['data'] is List) {
        if (!mounted) {
          return;
        }
        final List<ExportData> exports =
            (response['data'] as List).whereType<ExportData>().toList();
        setState(() => _allExportData = exports);
      }
    } catch (error) {
      debugPrint('Error loading partner export data: $error');
    }
  }

  void _logout() async {
    await ApiService.logout();
    if (!mounted) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  int get _totalUsers => _toInt(_stats['totalUsers']);
  int get _totalExports => _toInt(_stats['totalExports']);
  int get _totalImports => _toInt(_stats['totalImports']);
  int get _pendingTotal {
    final dynamic pending = _stats['pendingRequests'];
    if (pending is Map<String, dynamic>) {
      return _toInt(pending['total']);
    }
    return _toInt(_stats['pendingTotal']);
  }

  List<ExportData> get _periodExports {
    if (_allExportData.isEmpty) {
      return const [];
    }

    final DateTime now = DateTime.now();
    final DateTime endBoundary = DateTime(now.year, now.month, now.day + 1);
    final DateTime startBoundary =
        endBoundary.subtract(Duration(days: _selectedPeriod.days));

    return _allExportData.where((export) {
      final DateTime date = export.embarkationDate;
      return date.isAfter(startBoundary) && date.isBefore(endBoundary);
    }).toList();
  }

  bool _isApprovedStatus(String status) {
    final String normalized = status.toLowerCase().trim();
    return normalized == 'approved' || normalized == 'completed';
  }

  bool _isPendingStatus(String status) {
    final String normalized = status.toLowerCase().trim();
    return normalized == 'pending' || normalized == 'submitted';
  }

  int _sumBars(Iterable<ExportData> exports) {
    return exports.fold<int>(0, (sum, item) => sum + item.numberOfBars);
  }

  int _sumStraps(Iterable<ExportData> exports) {
    return exports.fold<int>(0, (sum, item) => sum + item.numberOfStraps);
  }

  int _sumSuctionCups(Iterable<ExportData> exports) {
    return exports.fold<int>(0, (sum, item) => sum + item.numberOfSuctionCups);
  }

  Iterable<ExportData> get _enCoursExports =>
      _periodExports.where((item) => _isPendingStatus(item.approvalStatus));

  Iterable<ExportData> get _partenaireExports =>
      _periodExports.where((item) => _isApprovedStatus(item.approvalStatus));

  int get _totalBars => _sumBars(_periodExports);

  int get _barsEnCours => _sumBars(_enCoursExports);

  int get _barsChezPartenaire => _sumBars(_partenaireExports);

  int get _sanglesEnCours => _sumStraps(_enCoursExports);

  int get _ventousesEnCours => _sumSuctionCups(_enCoursExports);

  int get _sanglesChezPartenaire => _sumStraps(_partenaireExports);

  int get _ventousesChezPartenaire => _sumSuctionCups(_partenaireExports);

  int get _barsTunisie =>
      max(0, _totalBars - _barsEnCours - _barsChezPartenaire);

  List<_ActivityPoint> get _activityPoints {
    final List<_ActivityPoint> fromExportData =
        _buildPeriodSeriesFromExportData(_selectedPeriod);
    if (fromExportData.isNotEmpty) {
      return fromExportData;
    }

    final List<_ActivityPoint> parsed =
        _parsePeriodSeriesFromApi(_selectedPeriod);
    if (parsed.isNotEmpty) {
      return parsed;
    }
    return _buildFallbackSeries(_selectedPeriod);
  }

  List<_ActivityPoint> _buildPeriodSeriesFromExportData(
      DashboardPeriod period) {
    if (_allExportData.isEmpty) {
      return const [];
    }

    final DateTime today = DateTime.now();
    final DateTime end = DateTime(today.year, today.month, today.day);
    final DateTime start = end.subtract(Duration(days: period.days - 1));

    final Map<String, int> tunisieByDay = {};
    final Map<String, int> enCoursByDay = {};
    final Map<String, int> partenaireByDay = {};

    for (final ExportData export in _allExportData) {
      final DateTime exportDate = DateTime(
        export.embarkationDate.year,
        export.embarkationDate.month,
        export.embarkationDate.day,
      );

      if (exportDate.isBefore(start) || exportDate.isAfter(end)) {
        continue;
      }

      final String key =
          '${exportDate.year}-${exportDate.month}-${exportDate.day}';

      if (_isApprovedStatus(export.approvalStatus)) {
        partenaireByDay[key] =
            (partenaireByDay[key] ?? 0) + export.numberOfBars;
      } else if (_isPendingStatus(export.approvalStatus)) {
        enCoursByDay[key] = (enCoursByDay[key] ?? 0) + export.numberOfBars;
      } else {
        tunisieByDay[key] = (tunisieByDay[key] ?? 0) + export.numberOfBars;
      }
    }

    return List.generate(period.days, (index) {
      final DateTime date = start.add(Duration(days: index));
      final String key = '${date.year}-${date.month}-${date.day}';
      final String label = _weekDays[date.weekday - 1];

      return _ActivityPoint(
        label: label,
        exports: tunisieByDay[key] ?? 0,
        imports: enCoursByDay[key] ?? 0,
        pending: partenaireByDay[key] ?? 0,
      );
    });
  }

  List<_ActivityPoint> _parsePeriodSeriesFromApi(DashboardPeriod period) {
    final dynamic periodContainer = _stats['activityByPeriod'] ??
        _stats['chartByPeriod'] ??
        _stats['dashboardByPeriod'];

    dynamic rawSeries;
    if (periodContainer is Map) {
      rawSeries = periodContainer[period.apiKey] ??
          periodContainer['${period.days}d'] ??
          periodContainer[period.days.toString()] ??
          periodContainer[period.label];
    }

    rawSeries ??= _stats['activitySeries'];
    if (rawSeries is! List) {
      return const [];
    }

    final List<_ActivityPoint> parsed = [];
    for (int i = 0; i < rawSeries.length; i++) {
      final dynamic item = rawSeries[i];
      if (item is! Map) {
        continue;
      }
      final String rawLabel =
          (item['label'] ?? item['day'] ?? item['date'] ?? '').toString();

      final String label = rawLabel.isEmpty
          ? _weekDays[i % _weekDays.length]
          : rawLabel.length > 5
              ? rawLabel.substring(0, 5).toLowerCase()
              : rawLabel;

      parsed.add(
        _ActivityPoint(
          label: label,
          exports: _toInt(item['exports'] ?? item['barres'] ?? item['bars']),
          imports: _toInt(item['imports'] ?? item['sangles'] ?? item['items']),
          pending: _toInt(
            item['pending'] ?? item['attente'] ?? item['ventouses'],
          ),
        ),
      );
    }

    return parsed;
  }

  List<_ActivityPoint> _buildFallbackSeries(DashboardPeriod period) {
    final int slots;
    switch (period) {
      case DashboardPeriod.last7Days:
        slots = 7;
        break;
      case DashboardPeriod.last15Days:
        slots = 8;
        break;
      case DashboardPeriod.last30Days:
        slots = 10;
        break;
    }

    final int safeExports = max(1, _totalExports);
    final int safeImports = max(1, _totalImports);
    final int safePending = max(1, _pendingTotal);
    final Random random =
        Random(period.days + safeExports + safeImports + safePending);

    int jitter(int base) {
      final int range = max(2, base ~/ 2);
      final int minValue = max(0, base - range);
      final int maxValue = base + range;
      return minValue + random.nextInt((maxValue - minValue) + 1);
    }

    final int exportBase = max(1, safeExports ~/ slots);
    final int importBase = max(1, safeImports ~/ slots);
    final int pendingBase = max(1, safePending ~/ slots);

    return List.generate(slots, (index) {
      final DateTime date =
          DateTime.now().subtract(Duration(days: (slots - 1) - index));
      final String label = _weekDays[date.weekday - 1];

      return _ActivityPoint(
        label: label,
        exports: jitter(exportBase),
        imports: jitter(importBase),
        pending: jitter(pendingBase),
      );
    });
  }

  List<_PieSlice> get _pieSlices {
    final double tunisie = _barsTunisie.toDouble();
    final double enCours = _barsEnCours.toDouble();
    final double partenaire = _barsChezPartenaire.toDouble();
    final double total = tunisie + enCours + partenaire;

    if (total <= 0) {
      return const [
        _PieSlice(label: 'Tunisie', value: 1, color: Color(0xFF0D9488)),
        _PieSlice(label: 'En cours', value: 1, color: Color(0xFFF6A23D)),
        _PieSlice(label: 'Chez partenaire', value: 1, color: Color(0xFF7E57C2)),
      ];
    }

    return [
      _PieSlice(
        label: 'Tunisie',
        value: tunisie,
        color: const Color(0xFF0D9488),
      ),
      _PieSlice(
        label: 'En cours',
        value: enCours,
        color: const Color(0xFFF6A23D),
      ),
      _PieSlice(
        label: 'Chez partenaire',
        value: partenaire,
        color: const Color(0xFF7E57C2),
      ),
    ];
  }

  List<_RecentActivityItem> get _recentActivities {
    final dynamic raw =
        _stats['recentActivities'] ?? _stats['latestActivities'];
    if (raw is List && raw.isNotEmpty) {
      return raw.whereType<Map>().take(4).map((item) {
        final String status = (item['status'] ?? 'En cours').toString();
        return _RecentActivityItem(
          date: (item['date'] ?? item['createdAt'] ?? 'Auj.').toString(),
          client: (item['client'] ?? item['clientName'] ?? '-').toString(),
          type: (item['type'] ?? item['referenceType'] ?? '-').toString(),
          status: status,
          statusColor: _statusColor(status),
        );
      }).toList();
    }

    final List<_ActivityPoint> points = _activityPoints;
    if (points.isEmpty) {
      return const [];
    }

    return [
      _RecentActivityItem(
        date: 'Auj.',
        client: 'Client A',
        type: 'Export',
        status: _pendingTotal > 0 ? 'En attente' : 'Valide',
        statusColor: _pendingTotal > 0 ? Colors.orange : Colors.green,
      ),
      const _RecentActivityItem(
        date: 'Hier',
        client: 'Client B',
        type: 'Import',
        status: 'Valide',
        statusColor: Colors.green,
      ),
    ];
  }

  Color _statusColor(String status) {
    final String normalized = status.toLowerCase();
    if (normalized.contains('reject')) {
      return Colors.red;
    }
    if (normalized.contains('attente') || normalized.contains('pending')) {
      return Colors.orange;
    }
    if (normalized.contains('valid') || normalized.contains('approve')) {
      return Colors.green;
    }
    return const Color(0xFF2F8DE4);
  }

  void _showEnCoursDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Details - En cours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Barres en cours', _barsEnCours, Colors.blue),
            const Divider(),
            _buildDetailRow('Sangles en cours', _sanglesEnCours, Colors.green),
            const Divider(),
            _buildDetailRow(
              'Ventouses en cours',
              _ventousesEnCours,
              Colors.orange,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showPartenaireDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Details - Chez partenaire (Confirme)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Barres confirmees',
              _barsChezPartenaire,
              Colors.blue,
            ),
            const Divider(),
            _buildDetailRow(
              'Sangles confirmees',
              _sanglesChezPartenaire,
              Colors.green,
            ),
            const Divider(),
            _buildDetailRow(
              'Ventouses confirmees',
              _ventousesChezPartenaire,
              Colors.orange,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE6E9F2),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1E3B70)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE6E9F2),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFFE6E9F2)),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.22,
                child: Image.asset(
                  'assets/images/backgrounds/login_background.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFD2DDF2), Color(0x00D2DDF2)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(child: _buildTopBar()),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildHeaderSection(),
                            const SizedBox(height: 16),
                            _buildOverviewCard(),
                            const SizedBox(height: 16),
                            _buildActivityBarChart(),
                            const SizedBox(height: 16),
                            _buildMiddleSection(),
                            const SizedBox(height: 24),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3B70).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Color(0xFF1E3B70),
              size: 22,
            ),
          ),
          const Column(
            children: [
              Text(
                'AST',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3B70),
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'Logitrack',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2F8DE4),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButtonWithBadge(
                icon: Icons.notifications_none,
                badgeCount: _unreadCount,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NotificationsScreen(user: widget.user),
                    ),
                  ).then((_) => _loadUnreadCount());
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  size: 24,
                  color: Color(0xFF1E3B70),
                ),
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenue ${widget.user.fullName}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3B70),
          ),
        ),
        const SizedBox(height: 12),
        _PeriodDropdown(
          selected: _selectedPeriod,
          onChanged: (DashboardPeriod value) {
            setState(() => _selectedPeriod = value);
          },
        ),
      ],
    );
  }

  Widget _buildOverviewCard() {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL BARRES',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: _totalBars),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    return Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 40,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'sur ${_selectedPeriod.label.toLowerCase()}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  title: 'Barres en Tunisie',
                  value: _barsTunisie,
                  icon: Icons.location_on_outlined,
                  textColor: const Color(0xFF0D9488),
                  backgroundColor: const Color(0xFFE6F7F5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatCard(
                  title: 'En cours',
                  value: _barsEnCours,
                  icon: Icons.sync,
                  textColor: const Color(0xFFED6C02),
                  backgroundColor: const Color(0xFFFFF3E0),
                  onTap: _showEnCoursDetails,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatCard(
                  title: 'Chez partenaire',
                  value: _barsChezPartenaire,
                  icon: Icons.business_outlined,
                  textColor: const Color(0xFF7E57C2),
                  backgroundColor: const Color(0xFFF2ECFC),
                  onTap: _showPartenaireDetails,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBarChart() {
    final List<_ActivityPoint> points = _activityPoints;
    final int maxValue = points
        .map((point) => max(point.exports, max(point.imports, point.pending)))
        .fold<int>(1, max);

    final double chartWidth = max(340, points.length * 46.0);

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evolution des barres ${_selectedPeriod.label.toLowerCase()}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3B70),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(points.length, (index) {
                  return _ActivityGroupBar(
                    point: points[index],
                    maxValue: maxValue,
                    index: index,
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: Color(0xFF0D9488), label: 'Tunisie'),
              SizedBox(width: 16),
              _LegendItem(color: Color(0xFFF6A23D), label: 'En cours'),
              SizedBox(width: 16),
              _LegendItem(color: Color(0xFF7E57C2), label: 'Chez partenaire'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              _buildPieChartCard(),
              const SizedBox(height: 16),
              _buildRecentActivity(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPieChartCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildRecentActivity()),
          ],
        );
      },
    );
  }

  Widget _buildPieChartCard() {
    final List<_PieSlice> slices = _pieSlices;
    final double total = slices.fold(0, (sum, slice) => sum + slice.value);

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Repartition des barres',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3B70),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return CustomPaint(
                    size: const Size(130, 130),
                    painter: _PieChartPainter(progress: value, slices: slices),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: slices.map((slice) {
                    final String percent =
                        '${((slice.value / total) * 100).round()}%';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            percent,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3B70),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: slice.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              slice.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final List<_RecentActivityItem> rows = _recentActivities;

    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activite Recente',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3B70),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Client',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Type', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Statut',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 6),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  'Aucune activite recente',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
            )
          else
            ...rows.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecentActivityRow(item: item),
              ),
            ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deconnexion'),
        content: const Text('Voulez-vous vraiment vous deconnecter ?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3B70),
            ),
            child: const Text(
              'Deconnexion',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
    this.onTap,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              Icon(icon, color: textColor.withValues(alpha: 0.6), size: 16),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown({
    required this.selected,
    required this.onChanged,
  });

  final DashboardPeriod selected;
  final ValueChanged<DashboardPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DashboardPeriod>(
          value: selected,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: DashboardPeriod.values
              .map(
                (period) => DropdownMenuItem<DashboardPeriod>(
                  value: period,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(period.label),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (DashboardPeriod? value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

class _ActivityGroupBar extends StatelessWidget {
  const _ActivityGroupBar({
    required this.point,
    required this.maxValue,
    required this.index,
  });

  final _ActivityPoint point;
  final int maxValue;
  final int index;

  double _heightFor(int value) {
    if (maxValue <= 0) {
      return 4;
    }
    final double normalized = (value / maxValue) * 72;
    return max(4, normalized);
  }

  Widget _buildBar(int value, Color color, int barOrder) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _heightFor(value)),
      duration: Duration(milliseconds: 650 + (index * 60) + (barOrder * 40)),
      curve: Curves.easeOutCubic,
      builder: (context, animatedHeight, child) {
        return Container(
          width: 10,
          height: animatedHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(point.exports, const Color(0xFF0D9488), 0),
            const SizedBox(width: 3),
            _buildBar(point.imports, const Color(0xFFF6A23D), 1),
            const SizedBox(width: 3),
            _buildBar(point.pending, const Color(0xFF7E57C2), 2),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          point.label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class _RecentActivityRow extends StatelessWidget {
  const _RecentActivityRow({required this.item});

  final _RecentActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            item.date,
            style: const TextStyle(fontSize: 10),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            item.client,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            item.type,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10),
          ),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.statusColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: item.statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  const _PieChartPainter({
    required this.progress,
    required this.slices,
  });

  final double progress;
  final List<_PieSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.butt;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width / 2, size.height / 2) - 9;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final double total = slices.fold(0, (sum, slice) => sum + slice.value);

    if (total <= 0) {
      return;
    }

    double startAngle = -pi / 2;
    for (final _PieSlice slice in slices) {
      paint.color = slice.color;
      final double sweep = (slice.value / total) * 2 * pi * progress;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += (slice.value / total) * 2 * pi;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.slices != slices;
  }
}
