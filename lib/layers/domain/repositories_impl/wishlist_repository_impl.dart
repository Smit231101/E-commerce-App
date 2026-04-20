import 'package:e_commerce_app/layers/data/datasources/local/local_wishlist_service.dart';
import 'package:e_commerce_app/layers/data/datasources/remote/firebase_firestore_service.dart';
import 'package:e_commerce_app/layers/data/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistRepository {
  final LocalWishlistService _localService;
  final FirebaseFirestoreService _firestoreService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WishlistRepository(this._localService, this._firestoreService);

  Future<List<ProductModel>> getWishlist() async {
    final user = _auth.currentUser;
    return user == null
        ? await _localService.getLocalWishlist()
        : await _firestoreService.getFirestoreWishlist(user.uid);
  }

  Future<void> toggleWishlistItem(ProductModel product) async {
    final user = _auth.currentUser;
    final currentList = await getWishlist();
    final isFavorited = currentList.any((p) => p.id == product.id);

    if (user == null) {
      // Local Toggle
      if (isFavorited) {
        currentList.removeWhere((p) => p.id == product.id);
      } else {
        currentList.add(product);
      }
      await _localService.saveLocalWishlist(currentList);
    } else {
      // Cloud Toggle
      if (isFavorited) {
        await _firestoreService.deleteFromFirestoreWishlist(
          user.uid,
          product.id.toString(),
        );
      } else {
        await _firestoreService.saveToFirestoreWishlist(user.uid, product);
      }
    }
  }

  // Called automatically on login (just like the cart!)
  Future<void> syncLocalWishlistToFirestore(String uid) async {
    final localItems = await _localService.getLocalWishlist();
    if (localItems.isEmpty) return;

    for (var item in localItems) {
      await _firestoreService.saveToFirestoreWishlist(uid, item);
    }
    await _localService.clearWishlist();
  }
}
