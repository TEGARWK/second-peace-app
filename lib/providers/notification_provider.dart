import 'package:flutter/material.dart';
import 'package:secondpeacem/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  int unreadCount = 0;

  Future<void> fetchUnreadCount() async {
    try {
      final data = await NotificationService().fetchNotifications();
      final count = data.where((n) => (n['is_read'] ?? 0) == 0).length;
      print('📦 Jumlah notifikasi belum dibaca: $count');
      unreadCount = count;
      notifyListeners();
    } catch (e) {
      print('❌ Gagal fetchUnreadCount: $e');
    }
  }

  void markAllAsRead() {
    unreadCount = 0;
    notifyListeners();
  }
}
