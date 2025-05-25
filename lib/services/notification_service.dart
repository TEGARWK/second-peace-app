import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final String baseUrl =
      'http://10.0.2.2:8000/api/v1'; // ganti kalau pakai hosting

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/notifikasi'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final notifications = List<Map<String, dynamic>>.from(
        data['notifications'],
      );

      print('=== RESPONSE NOTIFIKASI ===');
      print(response.body);

      for (var n in notifications) {
        final rawData = n['data'];
        if (rawData is String) {
          try {
            n['data'] = jsonDecode(rawData);
          } catch (e) {
            n['data'] = null; // fallback if string is malformed
          }
        }
      }

      return notifications;
    } else {
      throw Exception('Gagal memuat notifikasi');
    }
  }

  Future<void> markAsRead(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.patch(
      Uri.parse('$baseUrl/notifikasi/$id/baca'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menandai notifikasi');
    }
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<Map<String, dynamic>> fetchOrderDetail(int idPesanan) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/v1/pesanan/$idPesanan'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data['pesanan']);
    } else {
      throw Exception("Gagal mengambil detail pesanan");
    }
  }
}
