import 'package:e_commerce_app/core/router/app_router.dart';
import 'package:e_commerce_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class Luxe extends StatelessWidget {
  const Luxe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Luxe E-Commerce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
