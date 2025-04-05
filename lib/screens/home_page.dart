import 'package:flutter/material.dart';
import 'package:secondpeacem/models/product.dart';
import 'detail_page.dart';

class HomePage extends StatelessWidget {
  final List<Product> products;

  const HomePage({super.key, required this.products});

  static const List<String> categories = [
    'pria',
    'wanita',
    'sepatu',
    'aksesoris',
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 10),
          buildCategorySection(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 600 ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemBuilder:
                    (context, index) =>
                        _buildProductItem(context, products[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategorySection() {
    return SizedBox(
      height: 90,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryItem(categories[index]);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/$label.jpg'),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label[0].toUpperCase() + label.substring(1),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
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
                (context, animation, secondaryAnimation) =>
                    DetailPage(product: product, relatedProducts: products),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: Image.network(
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                          ? product.imageUrl!
                          : 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 50),
                          ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
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
                      "Rp ${product.price.toStringAsFixed(0)}",
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
}
