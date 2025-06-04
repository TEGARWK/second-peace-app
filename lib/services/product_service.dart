import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

const String baseUrl = 'https://secondpeace.my.id/api/v1';
//const String baseUrl = 'http://10.0.2.2:8000/api/v1';

class ProductService {
  Future<List<Product>> fetchProducts({String? kategori}) async {
    try {
      final uri =
          kategori != null
              ? Uri.parse('$baseUrl/products?kategori=$kategori')
              : Uri.parse('$baseUrl/products');

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Fleksibel terhadap key 'data' atau 'products'
        final productList = data['products'] ?? data['data'] ?? [];

        return List<Product>.from(
          productList.map((json) => Product.fromJson(json)),
        );
      } else {
        throw Exception('Gagal memuat produk (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat produk: $e');
    }
  }
}
