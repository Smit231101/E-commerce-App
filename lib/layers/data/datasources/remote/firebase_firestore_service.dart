import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/layers/data/models/cart_item_model.dart';
import 'package:e_commerce_app/layers/data/models/product_model.dart';
import 'package:e_commerce_app/layers/data/models/user_model.dart';
import 'package:flutter/foundation.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(user.toJson());
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? "Failed to save user profile in Firestore.");
    } catch (e) {
      throw Exception("Failed to save user profile: $e");
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firebaseFirestore.collection("users").doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } on FirebaseException catch (e) {
      throw Exception(
        e.message ?? "Failed to get user profile from Firestore.",
      );
    } catch (e) {
      throw Exception("Failed to get user profile: $e");
    }
  }

  Future<void> saveToFirestoreCart(String uid, CartItemModel items) async {
    try {
      await _firebaseFirestore
          .collection("users")
          .doc(uid)
          .collection("cartItems")
          .doc(items.productId.toString())
          .set(items.toJson());
    } catch (e) {
      if (kDebugMode) {
        print("Firestore save cart error: $e");
      }
      throw Exception('Failed to save to cloud cart: $e');
    }
  }

  Future<List<CartItemModel>> getFirestoreCart(String uid) async {
    try {
      final snapshot = await _firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('cartItems')
          .get();

      return snapshot.docs
          .map((doc) => CartItemModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cloud cart: $e');
    }
  }

  Future<void> deleteFromFirestoreCart(String uid, String productId) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('cartItems')
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete from cloud cart: $e');
    }
  }

  Future<void> saveToFirestoreWishlist(String uid, ProductModel product) async {
    await _firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(product.id.toString())
        .set(product.toJson());
  }

  Future<void> deleteFromFirestoreWishlist(String uid, String productId) async {
    await _firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .delete();
  }

  Future<List<ProductModel>> getFirestoreWishlist(String uid) async {
    final snapshot = await _firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data()))
        .toList();
  }
}
