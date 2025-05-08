import 'package:flutter/foundation.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? size;
  final String? imageUrl;
  final String? kategori; // ✅ Baru ditambahkan

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.stock = 0,
    this.size,
    this.imageUrl,
    this.kategori, // ✅ Tambahkan ke konstruktor
  });

  /// Digunakan untuk dummy data lokal
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      price:
          (map['price'] is int)
              ? (map['price'] as int).toDouble()
              : double.tryParse(map['price'].toString()) ?? 0.0,
      stock: map['stock'] ?? 0,
      size: map['size'],
      imageUrl: map['image'],
      kategori: map['kategori'], // ✅ Map lokal juga boleh
    );
  }

  /// Digunakan untuk data dari API Laravel
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
      name: json['nama_produk'] ?? '-',
      description: json['deskripsi'] ?? '',
      price: double.tryParse(json['harga'].toString()) ?? 0.0,
      stock: json['stok'] ?? 0,
      size: json['size'],
      imageUrl: imageUrl,
      kategori: json['kategori_produk'], // ✅ Ambil dari backend
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_produk': name,
      'deskripsi': description,
      'gambar': imageUrl,
      'harga': price,
      'stok': stock,
      'size': size,
      'kategori_produk': kategori, // ✅ Tambahkan ke output
    };
  }
}
