import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class NotificationsPage extends StatefulWidget {
  final String userId;

  const NotificationsPage({super.key, required this.userId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await http
          .get(Uri.parse('${AuthService().baseUrl}/api/notifications/${widget.userId}'), headers: AuthService().headers)
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _notifications = data['notifications'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await http.put(Uri.parse('${AuthService().baseUrl}/api/notifications/$id/read'), headers: AuthService().headers);
      _fetchNotifications();
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      await http.put(Uri.parse('${AuthService().baseUrl}/api/notifications/read-all/${widget.userId}'), headers: AuthService().headers);
      _fetchNotifications();
    } catch (_) {}
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'rent_reminder':
        return Icons.payment_outlined;
      case 'payment_reminder':
        return Icons.warning_amber_rounded;
      case 'payment_verified':
        return Icons.verified_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'rent_reminder':
        return const Color(0xFFD4A843);
      case 'payment_reminder':
        return Colors.red;
      case 'payment_verified':
        return Colors.green;
      default:
        return const Color(0xFF1A3A5C);
    }
  }

  String _timeAgo(String dateStr) {
    final dt = DateTime.parse(dateStr);
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (_notifications.any((n) => n['isRead'] == false))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 60, color: Color(0xFFD0C9BC)),
                      SizedBox(height: 16),
                      Text('No notifications yet', style: TextStyle(fontSize: 16, color: Color(0xFF6B6154))),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      final isUnread = n['isRead'] == false;
                      final type = n['type'] ?? 'system';

                      return GestureDetector(
                        onTap: isUnread ? () => _markAsRead(n['_id']) : null,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUnread ? Colors.white : const Color(0xFFF7F4EF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isUnread ? _colorForType(type).withOpacity(0.3) : const Color(0xFFE5DDD0),
                              width: isUnread ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _colorForType(type).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _iconForType(type),
                                  color: _colorForType(type),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n['title'] ?? '',
                                            style: TextStyle(
                                              fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                              fontSize: 14,
                                              color: const Color(0xFF1A3A5C),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _timeAgo(n['createdAt'] ?? ''),
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9080)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['message'] ?? '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isUnread ? const Color(0xFF4A4035) : const Color(0xFF9E9080),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isUnread)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, top: 4),
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD4A843),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
