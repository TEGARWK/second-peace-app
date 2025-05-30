import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/cart_provider.dart';
import 'checkout_page.dart';
import 'detail_page.dart';
import '../models/product.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCart());
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    await Provider.of<CartProvider>(context, listen: false).fetchCart();
    setState(() => _isLoading = false);
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
              backgroundColor: Colors.black,
            ),
            body:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : cartProvider.items.isEmpty
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
                              if (produk == null)
                                return const SizedBox.shrink();

                              final imageUrl =
                                  (produk['gambar'] != null &&
                                          produk['gambar']
                                              .toString()
                                              .startsWith('http'))
                                      ? produk['gambar']
                                      : 'http://10.0.2.2:8000/uploads/${produk['gambar']}';

                              final isSold = item['is_sold'] == true;

                              return FadeInUp(
                                duration: const Duration(milliseconds: 300),
                                child: Dismissible(
                                  key: Key(item['id_keranjang'].toString()),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (direction) async {
                                    await cartProvider.removeItem(
                                      item['id_keranjang'],
                                    );
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
                                      onTap:
                                          isSold
                                              ? null
                                              : () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) => DetailPage(
                                                          product: Product(
                                                            id:
                                                                produk['id_produk'],
                                                            name:
                                                                produk['nama_produk'],
                                                            description:
                                                                produk['deskripsi'],
                                                            price:
                                                                (produk['harga']
                                                                        as num)
                                                                    .toDouble(),
                                                            stock:
                                                                produk['stok'],
                                                            size:
                                                                produk['size'],
                                                            imageUrl: imageUrl,
                                                          ),
                                                          relatedProducts:
                                                              const [],
                                                        ),
                                                  ),
                                                );
                                              },
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (
                                                context,
                                                url,
                                              ) => Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey.shade300,
                                                ),
                                              ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                  ),
                                        ),
                                      ),
                                      title: Text(
                                        produk['nama_produk'] ?? 'Produk',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            formatRupiah(produk['harga'] ?? 0),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (isSold)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Stok habis • Produk sudah terjual habis',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.deepOrange,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
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
                                          onChanged:
                                              isSold
                                                  ? null
                                                  : (value) {
                                                    cartProvider.toggleSelect(
                                                      index,
                                                    );
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
                      checkColor: Colors.white,
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
                    formatRupiah(cartProvider.getTotalPrice),
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
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

              if (!isLoggedIn) {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Login Diperlukan"),
                        content: const Text(
                          "Silakan login terlebih dahulu untuk melanjutkan ke checkout.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Batal",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // tutup dialog
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                );
                return;
              }

              final selectedItems =
                  cartProvider.items
                      .where(
                        (item) =>
                            (item['selected'] ?? false) &&
                            item['is_sold'] != true,
                      )
                      .map(
                        (item) => {
                          'id_produk': item['produk']['id_produk'],
                          'name': item['produk']['nama_produk'] ?? 'Produk',
                          'price': item['produk']['harga'] ?? 0,
                          'quantity': item['jumlah'] ?? 1,
                          'image':
                              (() {
                                final gambar = item['produk']['gambar'];
                                return (gambar != null &&
                                        gambar.toString().startsWith('http'))
                                    ? gambar
                                    : 'http://10.0.2.2:8000/uploads/$gambar';
                              })(),
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
