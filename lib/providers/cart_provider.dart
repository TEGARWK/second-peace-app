import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  CartService cartService;

  CartProvider({required this.cartService});

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
      debugPrint('⚠️ fetchCart dibatalkan karena userId null');
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
      debugPrint('❌ Error fetchCart: $e');
    }
  }

  /// ➕ Tambah item ke keranjang (dengan pengecekan duplikat)
  Future<void> addItem({
    required int userId,
    required int produkId,
    required int jumlah,
    required String name,
    required String imageUrl,
    required int harga,
  }) async {
    try {
      // ✅ Cek apakah produk sudah ada di keranjang
      final alreadyInCart = _cartItems.any((item) {
        final itemProduk = item['produk'];
        return itemProduk != null && itemProduk['id_produk'] == produkId;
      });

      if (alreadyInCart) {
        debugPrint('⚠️ Produk ini sudah ada di keranjang!');
        throw Exception('Produk ini sudah ada di keranjang');
      }

      debugPrint(
        '[CartProvider] ➕ Tambah produk ID: $produkId untuk user $userId',
      );
      await cartService.addToCart(
        userId: userId,
        produkId: produkId,
        jumlah: jumlah,
      );
      await fetchCart(userId);
    } catch (e) {
      debugPrint('❌ Error addItem: $e');
      rethrow;
    }
  }

  /// ❌ Hapus item dari keranjang
  Future<void> removeItem(int keranjangId, int userId) async {
    try {
      await cartService.removeFromCart(keranjangId);
      await fetchCart(userId);
    } catch (e) {
      debugPrint('Error removeItem: $e');
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
      final harga = (item['produk']?['harga'] ?? 0) as num;
      final qty = (item['jumlah'] ?? 1) as num;
      return item['selected'] == true ? sum + (harga * qty).toInt() : sum;
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
