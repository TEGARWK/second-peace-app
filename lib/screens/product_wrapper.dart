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

  void _reloadProducts() {
    setState(() {
      _productFuture = ProductService().fetchProducts();
    });
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
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Gagal memuat produk:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _reloadProducts,
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            ),
          );
        } else {
          try {
            final List<Product> products = snapshot.data ?? [];
            if (products.isEmpty) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Belum ada produk tersedia',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            debugPrint('✅ Produk berhasil dimuat: ${products.length}');
            return const HomePage();
          } catch (e) {
            debugPrint('❌ Error parsing produk: $e');
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
