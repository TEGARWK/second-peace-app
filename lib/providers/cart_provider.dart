import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  CartService
  cartService; // ❗ ubah dari `final` ke normal agar bisa di-set ulang

  CartProvider({required this.cartService});

  // Setter untuk injeksi ulang cartService (digunakan setelah login)
  set setCartService(CartService newService) {
    cartService = newService;
  }

  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get items => _cartItems;

  int get totalItems => _cartItems.length;

  bool get isAllChecked =>
      _cartItems.isNotEmpty &&
      _cartItems.every((item) => item['selected'] == true);

  Future<void> fetchCart() async {
    try {
      final data = await cartService.fetchCartItems();
      _cartItems =
          data.map<Map<String, dynamic>>((item) {
            return {...(item as Map<String, dynamic>), 'selected': true};
          }).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetchCart: $e');
    }
  }

  Future<void> addItem(int produkId, int jumlah) async {
    try {
      await cartService.addToCart(produkId, jumlah);
      await fetchCart(); // refresh list setelah tambah
    } catch (e) {
      print('Error addItem: $e');
    }
  }

  Future<void> removeItem(int keranjangId) async {
    try {
      await cartService.removeFromCart(keranjangId);
      _cartItems.removeWhere((item) => item['id'] == keranjangId);
      notifyListeners();
    } catch (e) {
      print('Error removeItem: $e');
    }
  }

  void toggleSelect(int index) {
    _cartItems[index]['selected'] = !_cartItems[index]['selected'];
    notifyListeners();
  }

  void toggleSelectAll(bool value) {
    for (var item in _cartItems) {
      item['selected'] = value;
    }
    notifyListeners();
  }

  int getTotalPrice() {
    return _cartItems.fold<int>(0, (sum, item) {
      final price = (item['produk']['harga'] as num).toInt();
      final quantity = (item['jumlah'] as num).toInt();
      return item['selected'] == true ? sum + (price * quantity) : sum;
    });
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
