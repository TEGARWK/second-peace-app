import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get items => _cartItems;

  int get totalItems => _cartItems.length;

  bool get isAllChecked =>
      _cartItems.isNotEmpty &&
      _cartItems.every((item) => item['selected'] == true);

  void addItem(Map<String, dynamic> item) {
    _cartItems.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    _cartItems.removeAt(index);
    notifyListeners();
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

  /// ✅ FIXED: Total price calculation now handles int/double properly
  int getTotalPrice() {
    return _cartItems.fold<int>(0, (sum, item) {
      final price = (item['price'] as num).toInt();
      final quantity = (item['quantity'] as num).toInt();
      return item['selected'] == true ? sum + (price * quantity) : sum;
    });
  }

  void setItems(List<Map<String, dynamic>> items) {
    _cartItems = items;
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
