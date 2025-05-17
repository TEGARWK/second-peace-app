import 'package:flutter/foundation.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? size;
  final String? imageUrl;
  final String? kategori;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.stock = 0,
    this.size,
    this.imageUrl,
    this.kategori,
  });

  /// Untuk data dari API Laravel
  factory Product.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) debugPrint('🧩 JSON Produk: $json');

    final rawImage = json['gambar'];
    final imageUrl =
        rawImage != null
            ? (rawImage.toString().startsWith('http')
                ? rawImage
                : 'https://secondpeace.my.id/uploads/$rawImage')
            : null;

    return Product(
      id: json['id_produk'] ?? json['id'] ?? 0,
      name: json['nama_produk'] ?? json['name'] ?? '-',
      description: json['deskripsi'] ?? json['description'] ?? '',
      price: _toDouble(json['harga']),
      stock: int.tryParse(json['stok'].toString()) ?? 0,
      size: json['size'],
      imageUrl: imageUrl,
      kategori: json['kategori_produk'] ?? json['kategori'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produk': id,
      'nama_produk': name,
      'deskripsi': description,
      'gambar': imageUrl,
      'harga': price,
      'stok': stock,
      'size': size,
      'kategori_produk': kategori,
    };
  }

  /// Utility converter
  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is int) return val.toDouble();
    if (val is double) return val;
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
