import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'package:secondpeacem/screens/home_page.dart';

class ProductWrapper extends StatefulWidget {
  const ProductWrapper({super.key});

  @override
  State<ProductWrapper> createState() => _ProductWrapperState();
}

class _ProductWrapperState extends State<ProductWrapper> {
  late Future<List<Product>> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = ProductService().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Gagal memuat produk: ${snapshot.error}')),
          );
        } else {
          try {
            final List<Product> products = snapshot.data ?? [];
            print('✅ Produk berhasil dimuat: ${products.length}');
            return HomePage(products: products);
          } catch (e) {
            print('❌ Error parsing produk: $e');
            return const Scaffold(
              body: Center(
                child: Text(
                  'Produk tidak tersedia',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
        }
      },
    );
  }
}
