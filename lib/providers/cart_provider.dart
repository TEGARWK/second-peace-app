import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  CartService cartService;

  CartProvider({required this.cartService});

  // ✅ Setter jika ingin ganti CartService setelah login
  set setCartService(CartService newService) {
    cartService = newService;
    notifyListeners();
  }

  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get items => _cartItems;

  int get totalItems => _cartItems.length;

  bool get isAllChecked =>
      _cartItems.isNotEmpty &&
      _cartItems.every((item) => item['selected'] == true);

  /// 🔄 Ambil data keranjang dari backend
  Future<void> fetchCart(int userId) async {
    if (userId == null) {
      print('⚠️ fetchCart dibatalkan karena userId null');
      return;
    }

    try {
      final data = await cartService.fetchCartItems(userId);
      _cartItems =
          data
              .map<Map<String, dynamic>>((item) => {...item, 'selected': true})
              .toList();
      notifyListeners();
    } catch (e) {
      print('❌ Error fetchCart: $e');
    }
  }

  /// ➕ Tambah item ke keranjang
  Future<void> addItem({
    required int userId,
    required int produkId,
    required int jumlah,
    required String name,
    required String imageUrl,
    required int harga,
  }) async {
    try {
      print(
        '[CartProvider] ➕ addItem userId=$userId produkId=$produkId jumlah=$jumlah',
      );
      await cartService.addToCart(
        userId: userId,
        produkId: produkId,
        jumlah: jumlah,
      );
      await fetchCart(userId);
    } catch (e) {
      print('❌ Error addItem: $e');
      rethrow;
    }
  }

  /// ❌ Hapus item dari keranjang
  Future<void> removeItem(int keranjangId, int userId) async {
    try {
      await cartService.removeFromCart(keranjangId);
      await fetchCart(userId);
    } catch (e) {
      print('Error removeItem: $e');
    }
  }

  /// ✅ Toggle pilih item
  void toggleSelect(int index) {
    _cartItems[index]['selected'] = !_cartItems[index]['selected'];
    notifyListeners();
  }

  /// ✅ Pilih semua / batal semua
  void toggleSelectAll(bool value) {
    for (var item in _cartItems) {
      item['selected'] = value;
    }
    notifyListeners();
  }

  /// 💰 Total harga item terpilih
  int get getTotalPrice {
    return _cartItems.fold<int>(0, (sum, item) {
      final price = (item['produk']['harga'] as num).toInt();
      final quantity = (item['jumlah'] as num).toInt();
      return item['selected'] == true ? sum + (price * quantity) : sum;
    });
  }

  /// 🔢 Total qty item terpilih
  int getTotalQty() {
    return _cartItems.fold<int>(0, (sum, item) {
      final qty = (item['jumlah'] ?? 1) as int;
      return item['selected'] == true ? sum + qty : sum;
    });
  }

  /// ✅ Update token setelah login
  void updateToken(String newToken) {
    cartService = CartService(baseUrl: cartService.baseUrl, token: newToken);
    notifyListeners();
  }
}
