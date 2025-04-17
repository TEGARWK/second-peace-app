import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/cart_provider.dart';
import 'checkout_page.dart';
import 'detail_page.dart';
import '../models/product.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.fetchCart();
    });
  }

  String formatRupiah(dynamic value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(value);
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
                              final produk = item['produk'];
                              final imageUrl =
                                  produk['gambar'] != null
                                      ? 'http://192.168.1.4:8000/uploads/${produk['gambar']}'
                                      : null;

                              return FadeInUp(
                                duration: const Duration(milliseconds: 300),
                                child: Dismissible(
                                  key: Key(item['id'].toString()),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) async {
                                    await cartProvider.removeItem(item['id']);
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
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => DetailPage(
                                                  product: Product(
                                                    id: produk['id_produk'],
                                                    name: produk['nama_produk'],
                                                    description:
                                                        produk['deskripsi'],
                                                    price:
                                                        (produk['harga'] as num)
                                                            .toDouble(),
                                                    stock: produk['stok'],
                                                    size: produk['size'],
                                                    imageUrl: imageUrl,
                                                  ),
                                                  relatedProducts: const [],
                                                ),
                                          ),
                                        );
                                      },
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child:
                                            imageUrl != null
                                                ? Image.network(
                                                  imageUrl,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) =>
                                                          const Icon(
                                                            Icons.broken_image,
                                                          ),
                                                )
                                                : const Icon(
                                                  Icons.broken_image,
                                                ),
                                      ),
                                      title: Text(
                                        produk['nama_produk'] ?? 'Produk',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        formatRupiah(produk['harga'] ?? 0),
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
                    formatRupiah(cartProvider.getTotalPrice()),
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
                      .map(
                        (item) => {
                          'id': item['id'],
                          'name': item['produk']['nama_produk'] ?? 'Produk',
                          'price': (item['produk']['harga'] ?? 0),
                          'quantity': item['jumlah'] ?? 1,
                          'image':
                              item['produk']['gambar'] != null
                                  ? 'http://192.168.1.4:8000/uploads/${item['produk']['gambar']}'
                                  : null,
                        },
                      )
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
