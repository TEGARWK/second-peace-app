import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl;
  final String token;

  CartService({required this.baseUrl, required this.token});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// 🔄 Ambil semua item keranjang
  Future<List<dynamic>> fetchCartItems() async {
    final url = Uri.parse('$baseUrl/keranjang');

    print('[CartService] 🔽 GET: $url');
    print('[CartService] Token: $token');

    final response = await http.get(url, headers: headers);

    print('[CartService] Status: ${response.statusCode}');
    print('[CartService] Response: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data keranjang');
    }
  }

  /// ➕ Tambah produk ke keranjang
  Future<void> addToCart(int produkId, int jumlah) async {
    final body = jsonEncode({'produk_id': produkId, 'jumlah': jumlah});
    final url = Uri.parse('$baseUrl/keranjang/tambah');

    print('[CartService] 🔼 POST: $url');
    print('[CartService] Body: $body');
    print('[CartService] Token: $token');

    final response = await http.post(url, headers: headers, body: body);

    print('[CartService] Status: ${response.statusCode}');
    print('[CartService] Response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal menambahkan ke keranjang');
    }
  }

  /// ❌ Hapus produk dari keranjang
  Future<void> removeFromCart(int keranjangId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/keranjang/hapus/$keranjangId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus dari keranjang');
    }
  }
}
