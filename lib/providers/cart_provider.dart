import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Baju Pria Hitam',
      'price': 100000,
      'quantity': 1,
      'image': 'assets/baju.jpg',
      'selected': false,
    },
    {
      'name': 'Sepatu Sneakers',
      'price': 250000,
      'quantity': 1,
      'image': 'assets/sepatu.jpg',
      'selected': false,
    },
  ];

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

  int getTotalPrice() {
    return _cartItems.fold<int>(
      0,
      (sum, item) =>
          item['selected']
              ? sum + (item['price'] * item['quantity']) as int
              : sum,
    );
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
