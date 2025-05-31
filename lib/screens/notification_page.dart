import 'package:flutter/material.dart';
import 'package:secondpeacem/services/notification_service.dart';
import 'package:secondpeacem/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _notificationService = NotificationService();
  List<Map<String, dynamic>> notifications = [];
  bool loading = true;

  IconData getIconFromStatus(String status) {
    final s = status.trim().toLowerCase();

    if (s.contains('dikirim')) return Icons.local_shipping;
    if (s.contains('diterima')) return Icons.check_circle_outline;
    if (s.contains('dibatalkan')) return Icons.cancel;
    if (s.contains('menunggu')) return Icons.access_time;
    if (s.contains('diproses')) return Icons.settings;

    return Icons.notifications;
  }

  String getStatusFromNotif(Map<String, dynamic> notif) {
    final data = notif['data'];
    if (data == null) return '';
    try {
      final parsed = data is String ? jsonDecode(data) : data;
      final status = parsed['status_pesanan']?.toString() ?? '';
      print('🔍 Status dari notif: $status');
      return status;
    } catch (e) {
      print('❌ Gagal parsing status_pesanan: $e');
      return '';
    }
  }

  IconData getIconFromType(String type) {
    switch (type) {
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'pesanan':
        return Icons.local_shipping;
      default:
        return Icons.notifications;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await _notificationService.fetchNotifications();
      setState(() {
        notifications = data;
        loading = false;
      });

      // tandai sebagai dibaca (opsional bisa dibuat lebih presisi)
      for (var n in data.where((n) => (n['is_read'] ?? 0) == 0)) {
        await _notificationService.markAsRead(n['id']);
      }
      if (mounted) {
        context.read<NotificationProvider>().markAllAsRead();
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _markAsReadAndRefresh(int notifId) async {
    await _notificationService.markAsRead(notifId);
    await _loadNotifications(); // refresh agar titik merah hilang
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Notifikasi", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? const Center(child: Text("Belum ada notifikasi"))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final icon = getIconFromType(notif['type'] ?? '');

                  return GestureDetector(
                    onTap: () async {
                      print(
                        "Notifikasi diklik: ${notif['type']}, data: ${notif['data']}",
                      );

                      await _markAsReadAndRefresh(notif['id']);

                      if (notif['type'] == 'pesanan') {
                        if (notif['data'] == null) {
                          print("⚠️ Notifikasi pesanan tapi data null");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Data pesanan tidak tersedia"),
                            ),
                          );
                          return;
                        }

                        try {
                          final data =
                              notif['data'] is String
                                  ? Map<String, dynamic>.from(
                                    jsonDecode(notif['data']),
                                  )
                                  : notif['data'];

                          final detail = await _notificationService
                              .fetchOrderDetail(data['id_pesanan']);

                          if (!mounted) return;

                          Navigator.pushNamed(
                            context,
                            '/order-detail',
                            arguments: {
                              ...detail,
                              'status': detail['status_pesanan'],
                            },
                          );

                          print("Navigasi ke pesanan ${data['id_pesanan']}");
                        } catch (e) {
                          print("❌ Gagal decode data: $e");
                        }
                      } else if (notif['type'] == 'chat') {
                        Navigator.pushNamed(context, '/chat');
                      }
                    },

                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.black,
                              child: Icon(icon, color: Colors.white),
                            ),
                            if ((notif['is_read'] ?? 0) == 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          notif['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(notif['message']),
                            const SizedBox(height: 6),
                            Text(
                              notif['created_at'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
