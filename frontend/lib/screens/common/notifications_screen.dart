// ===========================================
// NOTIFICATIONS SCREEN
// ===========================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:import_export_app/models/notification_model.dart';
import 'package:import_export_app/models/user_model.dart';
import 'package:import_export_app/services/api_service.dart';
import 'package:import_export_app/widgets/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  final User user;

  const NotificationsScreen({super.key, required this.user});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    // Rafraîchir automatiquement toutes les 30 secondes
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadNotificationsQuietly();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Charger les notifications sans afficher le loading
  Future<void> _loadNotificationsQuietly() async {
    final response = await ApiService.getNotifications();

    if (response['success'] == true && mounted) {
      setState(() {
        _notifications = (response['notifications'] as List?)
                ?.map((n) => NotificationModel.fromJson(n))
                .toList() ??
            [];
        _unreadCount = response['unreadCount'] ?? 0;
      });
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final response = await ApiService.getNotifications();

    if (response['success'] == true && mounted) {
      setState(() {
        _notifications = (response['notifications'] as List?)
                ?.map((n) => NotificationModel.fromJson(n))
                .toList() ??
            [];
        _unreadCount = response['unreadCount'] ?? 0;
      });
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    await ApiService.markNotificationAsRead(notification.id);
    _loadNotificationsQuietly();
  }

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0) return;

    final response = await ApiService.markAllNotificationsAsRead();
    if (!mounted) return;
    if (response['success'] == true) {
      AppSnackBar.showSuccess(
          context, 'Toutes les notifications marquées comme lues');
      _loadNotificationsQuietly();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF0C44A6),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, color: Colors.white, size: 20),
              label: const Text(
                'Tout lire',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/login_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color(0x99000000),
              BlendMode.darken,
            ),
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                child: _notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'avez pas encore de notifications',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    // Group notifications by date
    final today = DateTime.now();
    final todayNotifications = <NotificationModel>[];
    final yesterdayNotifications = <NotificationModel>[];
    final olderNotifications = <NotificationModel>[];

    for (final notification in _notifications) {
      final diff = today.difference(notification.createdAt).inDays;
      if (diff == 0) {
        todayNotifications.add(notification);
      } else if (diff == 1) {
        yesterdayNotifications.add(notification);
      } else {
        olderNotifications.add(notification);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (todayNotifications.isNotEmpty) ...[
          _buildSectionHeader("Aujourd'hui"),
          ...todayNotifications.map(_buildNotificationCard),
        ],
        if (yesterdayNotifications.isNotEmpty) ...[
          _buildSectionHeader('Hier'),
          ...yesterdayNotifications.map(_buildNotificationCard),
        ],
        if (olderNotifications.isNotEmpty) ...[
          _buildSectionHeader('Plus ancien'),
          ...olderNotifications.map(_buildNotificationCard),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return NotificationCard(
      title: notification.title,
      message: notification.message,
      type: notification.type.toString().split('.').last,
      createdAt: notification.createdAt,
      isRead: notification.isRead,
      actionRequired: notification.needsAction,
      onTap: () {
        _markAsRead(notification);
        _showNotificationDetail(notification);
      },
    );
  }

  void _showNotificationDetail(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            _getNotificationIcon(notification.type),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.message),
              const SizedBox(height: 16),
              if (notification.senderName != null)
                Text(
                  'De: ${notification.senderName}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              Text(
                'Reçu le: ${_formatDateTime(notification.createdAt)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              if (notification.actionTaken != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: notification.actionTaken == 'approved'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    notification.actionTaken == 'approved'
                        ? '✅ Approuvé'
                        : '❌ Refusé',
                    style: TextStyle(
                      color: notification.actionTaken == 'approved'
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
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

  Widget _getNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.exportRequest:
        icon = Icons.upload;
        color = Colors.green;
        break;
      case NotificationType.importRequest:
        icon = Icons.download;
        color = Colors.blue;
        break;
      case NotificationType.approval:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case NotificationType.rejection:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} à ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
