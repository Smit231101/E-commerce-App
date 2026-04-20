import 'dart:async';

import 'package:e_commerce_app/layers/domain/repositories_impl/cart_repository_impl.dart';
import 'package:e_commerce_app/layers/data/models/cart_item_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CartViewModel extends ChangeNotifier {
  final CartRepositoryImpl _cartRepositoryImpl;
  StreamSubscription<User?>? _authSubscription;
  String? _activeUserId;

  CartViewModel(this._cartRepositoryImpl) {
    _activeUserId = FirebaseAuth.instance.currentUser?.uid;
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      final nextUserId = user?.uid;
      if (_activeUserId == nextUserId) {
        return;
      }

      _activeUserId = nextUserId;
      _items = [];
      notifyListeners();
      loadCart();
    });

    loadCart();
  }
  List<CartItemModel> _items = [];
  List<CartItemModel> get cartItems => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double get subtotal => _items.fold<double>(
    0.0,
    (sum, item) => sum + (item.price * item.quantity),
  );
  double get tax => subtotal * 0.05; // 5% luxury tax
  double get total => subtotal + tax;

  Future<void> addItem(CartItemModel item) async {
    await _cartRepositoryImpl.addToCart(item);
    await loadCart();
  }

  Future<void> loadCart() async {
    _activeUserId = FirebaseAuth.instance.currentUser?.uid;
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _cartRepositoryImpl.getCart();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- USER ACTIONS ---

  // 1. Increase Quantity
  Future<void> increaseQuantity(CartItemModel item) async {
    // Tell the repository to save the new quantity (+1)
    await _cartRepositoryImpl.updateQuantity(item, item.quantity + 1);

    // Reload the cart to refresh the UI and recalculate the subtotal!
    await loadCart();
  }

  // 2. Decrease Quantity
  Future<void> decreaseQuantity(CartItemModel item) async {
    if (item.quantity > 1) {
      // If they have more than 1, just subtract 1
      await _cartRepositoryImpl.updateQuantity(item, item.quantity - 1);
      await loadCart();
    } else {
      // If the quantity is exactly 1 and they press minus, we remove the item completely
      await removeItem(item.productId);
    }
  }

  // 3. Remove Item entirely (used by the swipe-to-delete Dismissible too)
  Future<void> removeItem(int productId) async {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index == -1) {
      return;
    }

    final removedItem = _items.removeAt(index);
    notifyListeners();

    try {
      await _cartRepositoryImpl.removeFromCart(productId);
      await loadCart();
    } catch (e) {
      _items.insert(index, removedItem);
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
