import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product_model.dart';

class LocalWishlistService {
  static const String _wishlistKey = 'local_wishlist_items';

  Future<List<ProductModel>> getLocalWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? wishlistString = prefs.getString(_wishlistKey);
    if (wishlistString == null) return [];
    
    final List<dynamic> decoded = jsonDecode(wishlistString);
    return decoded.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<void> saveLocalWishlist(List<ProductModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(items.map((i) => i.toJson()).toList());
    await prefs.setString(_wishlistKey, encoded);
  }

  Future<void> clearWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_wishlistKey);
  }
}