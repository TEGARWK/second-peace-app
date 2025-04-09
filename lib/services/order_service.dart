import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static const String baseUrl =
      'https://example.com/api'; // Ganti URL ini dengan URL server Anda

  /// Ambil semua pesanan berdasarkan status dan email
  static Future<List<Map<String, dynamic>>> getOrdersByStatus(
    String email,
    String status,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders?email=$email&status=$status'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal memuat data pesanan');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  /// Ambil jumlah pesanan per status (belum bayar, diproses, dikirim, selesai)
  static Future<Map<String, int>> getOrderCounts(String email) async {
    try {
      final statuses = ['belum bayar', 'diproses', 'dikirim', 'selesai'];
      final Map<String, int> counts = {};

      for (var status in statuses) {
        final response = await http.get(
          Uri.parse('$baseUrl/orders/count?email=$email&status=$status'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          counts[status] = data['count'] ?? 0;
        } else {
          counts[status] = 0;
        }
      }

      return counts;
    } catch (e) {
      print('Error fetching order counts: $e');
      return {'belum bayar': 0, 'diproses': 0, 'dikirim': 0, 'selesai': 0};
    }
  }
}
