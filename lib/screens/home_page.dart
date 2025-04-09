import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secondpeacem/data/dummy_products.dart';
import 'package:secondpeacem/models/product.dart';
import 'package:intl/intl.dart';
import 'detail_page.dart';

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
  bool _showCategories = true;
  double _lastOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      double currentOffset = _scrollController.offset;

      // Deteksi arah scroll manual
      if (currentOffset > _lastOffset && _showCategories) {
        // Scroll ke bawah, sembunyikan kategori
        setState(() {
          _showCategories = false;
        });
      } else if (currentOffset < _lastOffset && !_showCategories) {
        // Scroll ke atas, tampilkan kategori
        setState(() {
          _showCategories = true;
        });
      }

      _lastOffset = currentOffset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          slivers: [
            // Search Bar dan tombol kategori
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
                      onTap: () {
                        setState(() {
                          _showCategories = !_showCategories;
                        });
                      },
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
                transitionBuilder: (Widget child, Animation<double> animation) {
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
                          key: const ValueKey(
                            true,
                          ), // Important for AnimatedSwitcher
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

            // Produk grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildProductItem(context, dummyProducts[index]),
                  childCount: dummyProducts.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => DetailPage(
                  product: product,
                  relatedProducts: dummyProducts,
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
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

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50),
            ),
      );
    } else {
      return Image.asset(
        imagePath.isNotEmpty ? imagePath : 'assets/placeholder.png',
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50),
            ),
      );
    }
  }
}
