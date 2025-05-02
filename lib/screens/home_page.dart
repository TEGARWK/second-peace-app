import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import 'detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  final List<Product> products;
  const HomePage({super.key, required this.products});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<String> categories = [
    'pria',
    'wanita',
    'sepatu',
    'aksesoris',
  ];

  late ScrollController _scrollController;
  bool _showCategories = false; // 🔧 default tertutup
  bool _forceHideCategoryByScroll = false;
  double _lastOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      double currentOffset = _scrollController.offset;

      // Scroll ke bawah ➜ sembunyikan
      if (currentOffset > _lastOffset && _showCategories) {
        setState(() {
          _showCategories = false;
          _forceHideCategoryByScroll = true;
        });
      }

      // Scroll ke atas ➜ jangan tampilkan lagi otomatis
      _lastOffset = currentOffset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleCategory() {
    setState(() {
      _showCategories = !_showCategories;
      _forceHideCategoryByScroll = false; // reset scroll state
    });
  }

  String formatRupiah(double price) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Search & Kategori Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.all(12),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _toggleCategory,

                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.category),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Animated Category
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, -0.2),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
                child:
                    _showCategories
                        ? Padding(
                          key: const ValueKey(true),
                          padding: const EdgeInsets.only(top: 8, left: 16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  categories.map((label) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundImage: AssetImage(
                                              'assets/$label.jpg',
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            label[0].toUpperCase() +
                                                label.substring(1),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        )
                        : const SizedBox.shrink(key: ValueKey(false)),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Produk Grid dari data langsung (tanpa FutureBuilder)
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  final products = widget.products;

                  if (products.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('Tidak ada produk.')),
                    );
                  }

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 600 ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder:
                        (context, index) => _buildProductItem(
                          context,
                          products[index],
                          products,
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    Product product,
    List<Product> related,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (_, __, ___) =>
                    DetailPage(product: product, relatedProducts: related),
            transitionsBuilder:
                (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        shadowColor: Colors.black26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: _buildProductImage(product),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formatRupiah(product.price),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    final imagePath = product.imageUrl ?? '';

    if (imagePath.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 50),
      );
    }

    return CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.grey.shade300),
          ),
      errorWidget:
          (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50),
          ),
    );
  }
}
