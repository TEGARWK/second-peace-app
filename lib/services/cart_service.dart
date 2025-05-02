import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl;
  final String token;

  CartService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// 🔄 Ambil semua item keranjang untuk user tertentu
  Future<List<dynamic>> fetchCartItems(int userId) async {
    final url = Uri.parse('$baseUrl/keranjang/$userId');

    print('[CartService] Token digunakan: $token');
    print('[CartService] 🔽 GET: $url');

    final response = await http.get(url, headers: headers);

    print('[CartService] Status: ${response.statusCode}');
    print('[CartService] Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['keranjang'];
    } else {
      throw Exception('Gagal mengambil data keranjang\n${response.body}');
    }
  }

  /// ➕ Tambah produk ke keranjang
  Future<void> addToCart({
    required int userId,
    required int produkId,
    required int jumlah,
  }) async {
    final body = jsonEncode({
      'id_user': userId,
      'id_produk': produkId,
      'jumlah': jumlah,
    });

    final url = Uri.parse('$baseUrl/keranjang');

    print('[CartService] 🔼 POST: $url');
    print('[CartService] Body: $body');

    final response = await http.post(url, headers: headers, body: body);

    print('[CartService] Status: ${response.statusCode}');
    print('[CartService] Response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal menambahkan ke keranjang\n${response.body}');
    }
  }

  /// ❌ Hapus produk dari keranjang
  Future<void> removeFromCart(int keranjangId) async {
    final url = Uri.parse('$baseUrl/keranjang/$keranjangId');

    final response = await http.delete(url, headers: headers);

    print('[CartService] ❌ DELETE: $url');
    print('[CartService] Status: ${response.statusCode}');
    print('[CartService] Response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus dari keranjang\n${response.body}');
    }
  }
}
