import '../models/product.dart';

final List<Product> dummyProducts = [
  Product.fromMap({
    "id": 101,
    "name": "Sweater Vintage",
    "price": 75000,
    "image": "assets/sweater.jpg",
    "description": "Sweater vintage dengan bahan tebal dan nyaman.",
    "size": "M",
  }),
  Product.fromMap({
    "id": 102,
    "name": "Jaket Denim",
    "price": 120000,
    "image": "assets/jaket.jpg",
    "description": "Jaket denim klasik cocok untuk gaya casual.",
    "size": "L",
  }),
  Product.fromMap({
    "id": 103,
    "name": "Kaos Oversize",
    "price": 50000,
    "image": "assets/kaos.jpg",
    "description": "Kaos oversize warna hitam, unisex.",
    "size": "XL",
  }),
  Product.fromMap({
    "id": 104,
    "name": "Celana Cargo",
    "price": 95000,
    "image": "assets/cargo.jpg",
    "description": "Celana cargo dengan banyak kantong, cocok untuk outdoor.",
    "size": "L",
  }),
];
