import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> productList = data['products']; // Buka key "products"
      return productList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }
}
