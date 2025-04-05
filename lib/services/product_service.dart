import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body is List ? body : body['data'];

      // Debug log:
      for (var item in data) {
        print(
          'Produk dari API: ${item['name']} | Gambar: ${item['image_url']}',
        );
      }

      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }
}
