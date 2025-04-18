import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  _DetailPageState createState() => _DetailPageState();
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
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child:
                    imageUrl != null && imageUrl.startsWith('http')
                        ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _errorImage(),
                        )
                        : Image.asset(
                          imageUrl ?? 'assets/placeholder.png',
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _errorImage(),
                        ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  if (widget.product.size != null &&
                      widget.product.size!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Ukuran: ${widget.product.size}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    showFullDescription
                        ? (widget.product.description ?? '').trim()
                        : ((widget.product.description?.length ?? 0) > 100
                            ? "${widget.product.description!.substring(0, 100)}..."
                            : (widget.product.description ?? '').trim()),
                    maxLines: showFullDescription ? null : 3,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(
                        () => showFullDescription = !showFullDescription,
                      );
                    },
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

            // Tombol aksi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => CheckoutPage(
                                  selectedItems: [
                                    {
                                      'name': widget.product.name,
                                      'price': widget.product.price.toDouble(),
                                      'quantity': 1,
                                      'image':
                                          imageUrl ?? 'assets/placeholder.png',
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
                        elevation: 4,
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      // ✅ tambahkan child:
                      onPressed: () async {
                        try {
                          await Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).addItem(widget.product.id, 1);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produk ditambahkan ke keranjang!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Gagal menambahkan produk ke keranjang!',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
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
            ),
            const SizedBox(height: 30),

            // Produk Terkait
            if (relatedProducts.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Produk Lainnya",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
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
                          boxShadow: [
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
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child:
                                  relatedImage != null &&
                                          relatedImage.startsWith('http')
                                      ? Image.network(
                                        relatedImage,
                                        width: 130,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => _errorImage(),
                                      )
                                      : Image.asset(
                                        relatedImage ??
                                            'assets/placeholder.png',
                                        width: 130,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => _errorImage(),
                                      ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    related.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _errorImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.broken_image, size: 50)),
    );
  }
}
