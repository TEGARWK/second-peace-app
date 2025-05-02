class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final String? size;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.stock = 0,
    this.size,
    this.imageUrl,
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
              : map['price'] ?? 0.0,
      stock: map['stock'] ?? 0,
      size: map['size'],
      imageUrl: map['image'],
    );
  }

  /// Digunakan untuk data dari API Laravel
  factory Product.fromJson(Map<String, dynamic> json) {
    print('🧩 JSON Produk: $json');

    return Product(
      id: json['id_produk'] ?? json['id'] ?? 0,
      name: json['nama_produk'] ?? '-',
      description: json['deskripsi'] ?? '',
      price: (json['harga'] ?? 0).toDouble(),
      stock: json['stok'] ?? 0,
      size: json['size'],
      imageUrl:
          json['gambar'] != null
              ? (json['gambar'].toString().startsWith('http')
                  ? json['gambar']
                  : 'http://10.0.2.2:8000/uploads/${json['gambar']}')
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'stock': stock,
      'size': size,
    };
  }
}
