import 'package:e_commerce_app/core/network/api_client.dart';
import 'package:e_commerce_app/layers/data/datasources/local/local_cart_service.dart';
import 'package:e_commerce_app/layers/data/datasources/local/local_wishlist_service.dart';
import 'package:e_commerce_app/layers/data/datasources/remote/firebase_auth_service.dart';
import 'package:e_commerce_app/layers/data/datasources/remote/firebase_firestore_service.dart';
import 'package:e_commerce_app/layers/data/datasources/remote/razorpay_service.dart';
import 'package:e_commerce_app/layers/domain/repositories_impl/auth_repository_impl.dart';
import 'package:e_commerce_app/layers/domain/repositories_impl/cart_repository_impl.dart';
import 'package:e_commerce_app/layers/domain/repositories_impl/product_repository_impl.dart';
import 'package:e_commerce_app/layers/domain/repositories_impl/wishlist_repository_impl.dart';
import 'package:e_commerce_app/layers/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:e_commerce_app/layers/presentation/cart/viewmodels/cart_view_model.dart';
import 'package:e_commerce_app/layers/presentation/checkout/viewmodels/checkout_viewmodel.dart';
import 'package:e_commerce_app/layers/presentation/home/view_models/home_view_model.dart';
import 'package:e_commerce_app/layers/presentation/wishlist/viewmodel/wishlist_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  // 1. Added 'static' keyword
  // 2. Added 'List<SingleChildWidget>' type
  static List<SingleChildWidget> providersList = [
    ChangeNotifierProvider(
      create: (context) => HomeViewModel(ProductRepositoryImpl(ApiClient())),
    ),
    ChangeNotifierProvider(
      create: (context) => AuthViewmodel(
        AuthRepositoryImpl(FirebaseAuthService(), FirebaseFirestoreService()),
        CartRepositoryImpl(LocalCartService(), FirebaseFirestoreService()),
        WishlistRepository(LocalWishlistService(), FirebaseFirestoreService()),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => CartViewModel(
        CartRepositoryImpl(LocalCartService(), FirebaseFirestoreService()),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => CheckoutViewmodel(RazorpayService()),
    ),
    ChangeNotifierProvider(
      create: (context) => WishlistViewModel(
        WishlistRepository(LocalWishlistService(), FirebaseFirestoreService()),
      ),
    ),
  ];
}
