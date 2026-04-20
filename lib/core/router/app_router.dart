import 'package:e_commerce_app/layers/data/models/product_model.dart';
import 'package:e_commerce_app/layers/presentation/auth/screen/login_screen.dart';
import 'package:e_commerce_app/layers/presentation/auth/screen/register_screen.dart';
import 'package:e_commerce_app/layers/presentation/cart/screen/cart_screen.dart';
import 'package:e_commerce_app/layers/presentation/checkout/screens/checkout_screen.dart';
import 'package:e_commerce_app/layers/presentation/home/screen/home_screen.dart';
import 'package:e_commerce_app/layers/presentation/home/screen/root_screen.dart';
import 'package:e_commerce_app/layers/presentation/product_details/screen/product_detail_screen.dart';
import 'package:e_commerce_app/layers/presentation/profile/screen/profile_screen.dart';
import 'package:e_commerce_app/layers/presentation/splash/screen/splash_screen.dart';
import 'package:e_commerce_app/layers/presentation/wishlist/screen/wishlist_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(path: "/", builder: (context, state) => const SplashScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RootScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                // Replace with WishlistView if you made it
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/cart', builder: (context, state) => CartScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: "/product-detail",
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailScreen(products: product);
        },
      ),
      GoRoute(
        path: "/register",
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: "/login", builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: "/checkout",
        builder: (context, state) => const CheckoutScreen(),
      ),
    ],
  );
}
