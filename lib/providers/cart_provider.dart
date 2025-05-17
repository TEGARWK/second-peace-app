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
  Future<void> fetchCart() async {
    try {
      final data = await cartService.fetchCartItems();

      _cartItems =
          data.map<Map<String, dynamic>>((item) {
            final produk = item['produk'];

            if (produk == null) {
              return {
                ...item,
                'jumlah': 1,
                'selected': false,
                'is_sold': true,
                'produk': null,
              };
            }

            final stok = int.tryParse(produk['stok']?.toString() ?? '0') ?? 0;
            final harga = int.tryParse(produk['harga']?.toString() ?? '0') ?? 0;
            final jumlah = int.tryParse(item['jumlah']?.toString() ?? '1') ?? 1;

            final isSold = stok < 1;

            return {
              ...item,
              'jumlah': jumlah,
              'selected': !isSold,
              'is_sold': isSold,
              'produk': {...produk, 'stok': stok, 'harga': harga},
            };
          }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Gagal fetch cart: $e');
    }
  }

  /// ➕ Tambah item ke keranjang
  Future<void> addItem({
    required int produkId,
    required int jumlah,
    required String name,
    required String imageUrl,
    required int harga,
  }) async {
    try {
      final alreadyInCart = _cartItems.any((item) {
        final itemProduk = item['produk'];
        return itemProduk != null && itemProduk['id_produk'] == produkId;
      });

      if (alreadyInCart) throw Exception('Produk ini sudah ada di keranjang');

      await cartService.addToCart(produkId: produkId, jumlah: jumlah);
      await fetchCart();
    } catch (e) {
      debugPrint('❌ Gagal menambahkan item ke keranjang: $e');
      rethrow;
    }
  }

  /// ❌ Hapus item dari keranjang
  Future<void> removeItem(int keranjangId) async {
    try {
      await cartService.removeFromCart(keranjangId);
      await fetchCart();
    } catch (e) {
      debugPrint('❌ Gagal menghapus item dari keranjang: $e');
    }
  }

  /// ✅ Toggle satu item
  void toggleSelect(int index) {
    if (_cartItems[index]['is_sold'] == true) return;
    _cartItems[index]['selected'] = !_cartItems[index]['selected'];
    notifyListeners();
  }

  /// ✅ Toggle semua item
  void toggleSelectAll(bool value) {
    for (var item in _cartItems) {
      if (item['is_sold'] != true) {
        item['selected'] = value;
      }
    }
    notifyListeners();
  }

  /// 💰 Total harga semua item terpilih
  int get getTotalPrice {
    return _cartItems.fold<int>(0, (sum, item) {
      final harga = (item['produk']?['harga'] ?? 0) as num;
      final qty = (item['jumlah'] ?? 1) as num;
      return item['selected'] == true ? sum + (harga * qty).toInt() : sum;
    });
  }

  /// 🔢 Total jumlah qty item terpilih
  int getTotalQty() {
    return _cartItems.fold<int>(0, (sum, item) {
      final qty = (item['jumlah'] ?? 1) as int;
      return item['selected'] == true ? sum + qty : sum;
    });
  }

  /// 🔄 Update token saat login/register
  void updateToken(String newToken) {
    cartService = CartService(baseUrl: cartService.baseUrl, token: newToken);
    notifyListeners();
  }
}
