import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  // ✅ Gunakan URL lokal untuk pengembangan
  final String baseUrl = 'https://secondpeace.my.id/api/v1';
  //final String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // 🔐 Ambil token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 📦 Ambil semua pesanan user
  Future<List<Map<String, dynamic>>> fetchUserOrders() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak tersedia');

    final response = await http.get(
      Uri.parse('$baseUrl/pesanan'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['pesanan']);
    } else {
      throw Exception('Gagal memuat pesanan: ${response.body}');
    }
  }

  // 🔄 Update status pesanan
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    required String resi,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak tersedia');

    final response = await http.put(
      Uri.parse('$baseUrl/pesanan/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': status, 'resi': resi}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal update status: ${response.body}');
    }
  }

  // 📊 Hitung jumlah pesanan berdasarkan status
  Future<Map<String, int>> getOrderCounts(String email) async {
    try {
      final orders = await fetchUserOrders();

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
          counts[tab] = counts[tab]! + 1;
        }
      }

      return counts;
    } catch (e) {
      throw Exception('Gagal menghitung pesanan: $e');
    }
  }

  // 🔁 Mapping status dari backend ke frontend tab
  String _mapStatusToTab(String status) {
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

  Future<Map<String, int>> getOrderCountsByStatus() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token tidak tersedia');

    final response = await http.get(
      Uri.parse('$baseUrl/pesanan'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List orders = data['pesanan'];

      final Map<String, int> statusCounts = {
        'Belum Bayar': 0,
        'Diproses': 0,
        'Dikirim': 0,
        'Selesai': 0,
      };

      for (var order in orders) {
        final status = order['status_pesanan'];
        switch (status) {
          case 'Menunggu Pembayaran':
            statusCounts['Belum Bayar'] = statusCounts['Belum Bayar']! + 1;
            break;
          case 'Pembayaran Diterima':
          case 'Sedang Diproses':
            statusCounts['Diproses'] = statusCounts['Diproses']! + 1;
            break;
          case 'Pesanan Dikirim':
            statusCounts['Dikirim'] = statusCounts['Dikirim']! + 1;
            break;
          case 'Pesanan Diterima':
            statusCounts['Selesai'] = statusCounts['Selesai']! + 1;
            break;
        }
      }

      return statusCounts;
    } else {
      throw Exception('Gagal memuat pesanan: ${response.body}');
    }
  }
}
