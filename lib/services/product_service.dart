import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  final String baseUrl = 'https://secondpeace.my.id/api'; // ✅ DOMAIN hosting

  Future<List<Product>> fetchProducts({String? kategori}) async {
    try {
      final url = Uri.parse(
        kategori != null
            ? '$baseUrl/products?kategori=$kategori'
            : '$baseUrl/products',
      );

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> productList = data['products'] ?? [];
        return productList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat produk (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat produk: $e');
    }
  }
}
