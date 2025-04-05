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
    required this.stock,
    this.size,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageUrl =
        json['image_url'] != null
            ? 'http://10.0.2.2:8000/storage/${json['image_url']}'
            : null;

    print('Membuat Product: ${json['name']} - ImageURL: $imageUrl');

    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      stock: json['stock'] ?? 0,
      size: json['size'],
      imageUrl: imageUrl,
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
