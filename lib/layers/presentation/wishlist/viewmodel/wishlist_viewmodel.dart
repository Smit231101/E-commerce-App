import 'package:e_commerce_app/layers/data/models/product_model.dart';
import 'package:e_commerce_app/layers/domain/repositories_impl/wishlist_repository_impl.dart';
import 'package:flutter/material.dart';

class WishlistViewModel extends ChangeNotifier {
  final WishlistRepository _repository;

  List<ProductModel> _items = [];
  List<ProductModel> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  WishlistViewModel(this._repository) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _repository.getWishlist();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(ProductModel product) async {
    // Optimistic UI update: Toggle instantly for a snappy feel, then save to DB
    final isFavorited = isFavorite(product.id);
    if (isFavorited) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();

    await _repository.toggleWishlistItem(product);
    await loadWishlist(); // Ensure sync with DB
  }

  // Helper method for the UI to check if the heart should be solid or outlined
  bool isFavorite(int productId) {
    return _items.any((item) => item.id == productId);
  }
}
