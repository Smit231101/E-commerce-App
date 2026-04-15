import 'package:e_commerce_app/layers/presentation/home/home_screen.dart';
import 'package:e_commerce_app/layers/presentation/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(path: "/", builder: (context, state) => const SplashScreen()),
      GoRoute(path: "/home", builder: (context, state) => const HomeScreen()),
    ],
  );
}
