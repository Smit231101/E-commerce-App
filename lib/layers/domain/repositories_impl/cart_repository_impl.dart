import 'package:e_commerce_app/layers/data/datasources/local/local_cart_service.dart';
import 'package:e_commerce_app/layers/data/datasources/remote/firebase_firestore_service.dart';
import 'package:e_commerce_app/layers/data/models/cart_item_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CartRepositoryImpl {
  final LocalCartService _localCartService;
  final FirebaseFirestoreService _firestoreService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CartRepositoryImpl(this._localCartService, this._firestoreService);

  Future<void> addToCart(CartItemModel newItem) async {
    final user = _auth.currentUser;

    if (user == null) {
      final localCart = await _localCartService.getLocalCartItems();

      final existingIndex = localCart.indexWhere(
        (item) => item.productId == newItem.productId,
      );

      if (existingIndex >= 0) {
        localCart[existingIndex].quantity += newItem.quantity;
      } else {
        localCart.add(newItem);
      }
      await _localCartService.saveLocalCartItems(localCart);
    } else {
      final cloudCart = await _firestoreService.getFirestoreCart(user.uid);
      final existingIndex = cloudCart.indexWhere(
        (item) => item.productId == newItem.productId,
      );

      if (existingIndex >= 0) {
        final existingItem = cloudCart[existingIndex];
        existingItem.quantity += newItem.quantity;
        await _firestoreService.saveToFirestoreCart(user.uid, existingItem);
      } else {
        await _firestoreService.saveToFirestoreCart(user.uid, newItem);
      }
    }
  }

  Future<void> syncLocalCartToFirestore(String uid) async {
    try {
      final LocalCart = await _localCartService.getLocalCartItems();

      if (LocalCart.isEmpty) return;

      for (var item in LocalCart) {
        await _firestoreService.saveToFirestoreCart(uid, item);
      }
      await _localCartService.clearCart();
    } catch (e) {
      if (kDebugMode) {
        print("Sync Error (cart related) : $e");
      }
    }
  }

  Future<List<CartItemModel>> getCart() async {
    final user = _auth.currentUser;

    if (user == null) {
      return await _localCartService.getLocalCartItems();
    } else {
      return await _firestoreService.getFirestoreCart(user.uid);
    }
  }

  Future<void> removeFromCart(int productId) async {
    final user = _auth.currentUser;

    if (user == null) {
      final localCart = await _localCartService.getLocalCartItems();
      localCart.removeWhere((item) => item.productId == productId);
      await _localCartService.saveLocalCartItems(localCart);
    } else {
      await _firestoreService.deleteFromFirestoreCart(
        user.uid,
        productId.toString(),
      );
    }
  }

  Future<void> updateQuantity(CartItemModel item, int newQuantity) async {
    final updatedItem = CartItemModel(
      productId: item.productId,
      title: item.title,
      price: item.price,
      thumbnail: item.thumbnail,
      quantity: newQuantity,
    );

    final user = _auth.currentUser;

    if (user == null) {
      final localCart = await _localCartService.getLocalCartItems();
      final existingIndex = localCart.indexWhere(
        (cartItem) => cartItem.productId == item.productId,
      );

      if (existingIndex >= 0) {
        localCart[existingIndex] = updatedItem;
      } else {
        localCart.add(updatedItem);
      }

      await _localCartService.saveLocalCartItems(localCart);
    } else {
      await _firestoreService.saveToFirestoreCart(user.uid, updatedItem);
    }
  }
}
