import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../screens/checkout_page.dart';
import '../widgets/custom_navbar.dart';
import '../providers/cart_provider.dart';

class DetailPage extends StatefulWidget {
  final Product product;
  final List<Product> relatedProducts;

  const DetailPage({
    super.key,
    required this.product,
    required this.relatedProducts,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool showFullDescription = false;

  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product.imageUrl;
    final relatedProducts =
        widget.relatedProducts.where((p) => p.id != widget.product.id).toList();

    return Scaffold(
      appBar: const CustomNavbar(
        isDetailPage: true,
        showCart: true,
        title: "Detail Produk",
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product-${widget.product.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child:
                    imageUrl != null && imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _shimmerImage(),
                          errorWidget: (context, url, error) => _errorImage(),
                        )
                        : _errorImage(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency.format(widget.product.price),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.product.kategori?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.label_outline,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Kategori: ${widget.product.kategori}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.product.size?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Ukuran: ${widget.product.size}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    "Stok: ${widget.product.stock}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    showFullDescription
                        ? (widget.product.description ?? '').trim()
                        : _shortenDesc(widget.product.description ?? ''),
                    maxLines: showFullDescription ? null : 3,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed:
                        () => setState(
                          () => showFullDescription = !showFullDescription,
                        ),
                    child: Text(
                      showFullDescription
                          ? "Lihat Lebih Sedikit"
                          : "Lihat Selengkapnya",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context, imageUrl),
            const SizedBox(height: 30),
            if (relatedProducts.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Produk Lainnya",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              _buildRelatedProducts(relatedProducts),
            ],
          ],
        ),
      ),
    );
  }

  String _shortenDesc(String desc) {
    return desc.length > 100 ? "${desc.substring(0, 100)}..." : desc;
  }

  Widget _shimmerImage() => Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: double.infinity,
      height: 300,
      color: Colors.grey.shade300,
    ),
  );

  Widget _errorImage() => Container(
    color: Colors.grey[300],
    width: double.infinity,
    height: 300,
    child: const Center(child: Icon(Icons.broken_image, size: 50)),
  );

  Widget _buildActionButtons(BuildContext context, String? imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

                if (!isLoggedIn) {
                  // ✅ Tampilkan dialog login
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text("Login Diperlukan"),
                          content: const Text(
                            "Silakan login terlebih dahulu untuk melakukan pembelian.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                "Batal",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // tutup dialog
                                Navigator.pushNamed(
                                  context,
                                  '/login',
                                ); // arahkan ke login
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                  );
                  return;
                }

                // ✅ Jika login, lanjut ke checkout
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => CheckoutPage(
                          selectedItems: [
                            {
                              'id_produk': widget.product.id,
                              'name': widget.product.name,
                              'price': widget.product.price.toDouble(),
                              'quantity': 1,
                              'image': imageUrl ?? 'assets/placeholder.png',
                            },
                          ],
                        ),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Beli Sekarang",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () async {
                try {
                  await Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).addItem(
                    produkId: widget.product.id,
                    jumlah: 1,
                    name: widget.product.name,
                    imageUrl: imageUrl ?? 'assets/placeholder.png',
                    harga: widget.product.price.toInt(),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produk ditambahkan ke keranjang!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  final isDuplicate = e.toString().contains('409');
                  final message =
                      isDuplicate
                          ? 'Produk ini sudah ada di keranjang.'
                          : 'Gagal menambahkan ke keranjang!';
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              },
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black87,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts(List<Product> relatedProducts) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: relatedProducts.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final related = relatedProducts[index];
          final relatedImage = related.imageUrl;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => DetailPage(
                        product: related,
                        relatedProducts: relatedProducts,
                      ),
                ),
              );
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: relatedImage ?? '',
                      width: 130,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _shimmerImage(),
                      errorWidget: (context, url, error) => _errorImage(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          related.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatCurrency.format(related.price),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
