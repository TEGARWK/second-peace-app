import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:secondpeacem/screens/cart_page.dart';
import '../providers/cart_provider.dart';

class CustomNavbar extends StatefulWidget implements PreferredSizeWidget {
  final bool isDetailPage;
  final bool showSearchBox; // Pastikan parameter ini ada
  final String? title;
  final bool showCart;

  const CustomNavbar({
    super.key,
    this.isDetailPage = false,
    this.showSearchBox = false, // Pastikan ini juga ada di konstruktor
    this.title,
    this.showCart = true,
  });

  @override
  _CustomNavbarState createState() => _CustomNavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _CustomNavbarState extends State<CustomNavbar> {
  bool showSearchBox = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          Container(height: 100, color: Colors.white),
          AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
            elevation: 4,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.black,
              statusBarIconBrightness: Brightness.light,
            ),
            toolbarHeight: 80,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            leading:
                widget.isDetailPage
                    ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                    : null,
            title: showSearchBox ? _buildSearchBox() : _buildTitleOrLogo(),
            actions: [
              if (!showSearchBox && widget.showCart) ...[
                Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return Stack(
                      children: [
                        IconButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CartPage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                          ),
                        ),
                        if (cart.totalItems > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  '${cart.totalItems}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleOrLogo() {
    if (widget.title != null) {
      return Text(
        widget.title!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/logo.png', width: 90, fit: BoxFit.contain),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white, size: 26),
          onPressed: () {
            setState(() {
              showSearchBox = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Cari Produk...",
          hintStyle: const TextStyle(fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              setState(() {
                showSearchBox = false;
              });
            },
          ),
        ),
      ),
    );
  }
}
