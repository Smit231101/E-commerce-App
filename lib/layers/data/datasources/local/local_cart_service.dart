import 'dart:convert';

import 'package:e_commerce_app/layers/data/models/cart_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCartService {
  static const String _cartKey = "local_cart_items";

  Future<List<CartItemModel>> getLocalCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString(_cartKey);
    if (cartString == null) {
      return [];
    }
    final List<dynamic> decodedList = jsonDecode(cartString);
    return decodedList.map((json) => CartItemModel.fromJson(json)).toList();
  }

  Future<void> saveLocalCartItems(List<CartItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, cartString);
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
