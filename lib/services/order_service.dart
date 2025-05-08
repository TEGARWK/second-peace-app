import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, int>> getOrderCounts(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pesanan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List orders = data['pesanan'];

        // Inisialisasi counter
        final Map<String, int> counts = {
          'Belum Bayar': 0,
          'Diproses': 0,
          'Dikirim': 0,
          'Selesai': 0,
        };

        for (var o in orders) {
          final status = o['status_pesanan'];
          final tab = _mapStatusToTab(status);
          if (counts.containsKey(tab)) {
            counts[tab] = (counts[tab] ?? 0) + 1;
          }
        }

        return counts;
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (e) {
      print('Error getOrderCounts: $e');
      return {'Belum Bayar': 0, 'Diproses': 0, 'Dikirim': 0, 'Selesai': 0};
    }
  }

  static String _mapStatusToTab(String status) {
    switch (status) {
      case 'Menunggu Pembayaran':
        return 'Belum Bayar';
      case 'Pembayaran Diterima':
      case 'Sedang Diproses':
        return 'Diproses';
      case 'Pesanan Dikirim':
        return 'Dikirim';
      case 'Pesanan Diterima':
        return 'Selesai';
      default:
        return 'Lainnya';
    }
  }
}
