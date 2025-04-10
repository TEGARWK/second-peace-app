import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/cart_provider.dart';
import 'checkout_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

import '../data/dummy_accounts.dart';
import '../data/dummy_products.dart'; // ⬅️ Tambahan ini penting

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        final user = dummyAccounts.firstWhere(
          (acc) => acc['id'] == userId,
          orElse: () => {},
        );

        if (user.isNotEmpty && user.containsKey('cart')) {
          final cartProvider = Provider.of<CartProvider>(
            context,
            listen: false,
          );

          final userCart = List<Map<String, dynamic>>.from(user['cart']);

          final detailedCart =
              userCart.map((cartItem) {
                final product = dummyProducts.firstWhere(
                  (prod) => prod.id == cartItem['productId'],
                  orElse:
                      () => Product(
                        id: 0,
                        name: 'Produk tidak ditemukan',
                        description: '',
                        price: 0.0,
                        stock: 0,
                        size: '',
                        imageUrl: 'assets/images/placeholder.png',
                      ),
                );

                return {
                  'productId': cartItem['productId'],
                  'name': product.name,
                  'price': product.price,
                  'image': product.imageUrl ?? 'assets/images/placeholder.png',
                  'quantity': cartItem['quantity'],
                  'selected': cartItem['selected'] ?? false,
                };
              }).toList();

          cartProvider.setItems(detailedCart);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder:
          (context, cartProvider, _) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Keranjang',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            body:
                cartProvider.items.isEmpty
                    ? const Center(
                      child: Text(
                        'Keranjang kosong',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: cartProvider.items.length,
                            itemBuilder: (context, index) {
                              final item = cartProvider.items[index];
                              return FadeInUp(
                                duration: const Duration(milliseconds: 300),
                                child: Dismissible(
                                  key: Key(item['name'] ?? 'item-$index'),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) {
                                    cartProvider.removeItem(index);
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    color: Colors.red,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          item['image'] ??
                                              'assets/images/placeholder.png',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(
                                        item['name'] ?? 'Produk',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Rp ${item['price'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Transform.scale(
                                        scale: 1.2,
                                        child: Checkbox(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                          ),
                                          value: item['selected'] ?? false,
                                          activeColor: Colors.green,
                                          onChanged: (value) {
                                            cartProvider.toggleSelect(index);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        _buildBottomBar(cartProvider),
                      ],
                    ),
          ),
    );
  }

  Widget _buildBottomBar(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      value: cartProvider.isAllChecked,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        cartProvider.toggleSelectAll(value ?? false);
                      },
                    ),
                  ),
                  const Text('Pilih Semua', style: TextStyle(fontSize: 16)),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Total: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp ${cartProvider.getTotalPrice()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              final selectedItems =
                  cartProvider.items
                      .where((item) => item['selected'] ?? false)
                      .toList();
              if (selectedItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pilih produk untuk checkout!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutPage(selectedItems: selectedItems),
                  ),
                );
              }
            },
            child: const Text(
              'Checkout',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
