import 'package:e_commerce_app/core/router/app_router.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Luxe E-Commerce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.black,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
      ),
      routerConfig: AppRouter.router,
    );
  }
}