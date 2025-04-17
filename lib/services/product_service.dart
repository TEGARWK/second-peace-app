import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String baseUrl = 'http://192.168.1.4:8000/api';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> productList = data['products'];
      return productList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }

  Future<Product> fetchProductById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data['product']);
    } else {
      throw Exception('Produk tidak ditemukan');
    }
  }
}
