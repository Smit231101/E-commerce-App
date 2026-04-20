import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/layers/data/models/cart_item_model.dart';
import 'package:e_commerce_app/layers/data/models/product_model.dart';
import 'package:e_commerce_app/layers/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:e_commerce_app/layers/presentation/cart/viewmodels/cart_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel products;
  const ProductDetailScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewmodel>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_image_${products.id}',
                child: CachedNetworkImage(
                  imageUrl: products.thumbnail,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    products.category.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface.withOpacity(0.56),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    products.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (authViewModel.isLoggedIn)
                    _buildUnlockDetails(context, product: products),
                  if (!authViewModel.isLoggedIn) _buildAuthWall(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          color: scheme.surface,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                final cartViewModel = context.read<CartViewModel>();
                final cartItem = CartItemModel(
                  productId: products.id,
                  title: products.title,
                  price: products.price,
                  thumbnail: products.thumbnail,
                );

                try {
                  await cartViewModel.addItem(cartItem);
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to Cart!')),
                  );
                } catch (_) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add item to cart.')),
                  );
                }
              },
              child: const Text(
                'ADD TO CART',
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthWall(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final panelColor = Color.alphaBlend(
      scheme.primary.withOpacity(0.04),
      scheme.surface,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 40,
            color: scheme.onSurface.withOpacity(0.62),
          ),
          const SizedBox(height: 16),
          Text(
            'Unlock Full Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create an account to view product descriptions, high-resolution galleries, and customer reviews.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withOpacity(0.62),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              context.push('/register');
            },
            child: const Text(
              'REGISTER / SIGN IN',
              style: TextStyle(letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockDetails(
    BuildContext context, {
    required ProductModel product,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const double usdToInr = 93.25;
    final double priceInInr = product.price * usdToInr;
    final double originalPrice = priceInInr / (1 - 0.15);
    final statsCardColor = isDark ? scheme.surface : scheme.primary;
    final statsForeground = isDark ? scheme.onSurface : scheme.onPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '₹${priceInInr.toStringAsFixed(0)}',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SAVE 15%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'MSRP: ₹${originalPrice.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: scheme.onSurface.withOpacity(0.56),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                Icon(Icons.stars_rounded, color: scheme.secondary, size: 28),
                Text(
                  '4.9 Rating',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withOpacity(0.58),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 28),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildModernChip(context, Icons.category_outlined, product.category),
              _buildModernChip(context, Icons.verified_outlined, 'Verified'),
              _buildModernChip(
                context,
                Icons.history_toggle_off_rounded,
                '7 Day Return',
              ),
              _buildModernChip(context, Icons.inventory_2_outlined, 'In Stock'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              color: scheme.secondary,
            ),
            const SizedBox(width: 10),
            Text(
              'PRODUCT OVERVIEW',
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: scheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          product.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color: scheme.onSurface.withOpacity(0.72),
            height: 1.8,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 40),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: statsCardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(isDark ? 0.18 : 0.16),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Global',
                'Shipping',
                foregroundColor: statsForeground,
              ),
              Container(
                width: 1,
                height: 30,
                color: statsForeground.withOpacity(0.18),
              ),
              _buildStatItem(
                context,
                'Secure',
                'Payments',
                foregroundColor: statsForeground,
              ),
              Container(
                width: 1,
                height: 30,
                color: statsForeground.withOpacity(0.18),
              ),
              _buildStatItem(
                context,
                '24/7',
                'Support',
                foregroundColor: statsForeground,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernChip(BuildContext context, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: scheme.surface,
        border: Border.all(color: scheme.outline.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: scheme.primary.withOpacity(0.92)),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String top,
    String bottom, {
    required Color foregroundColor,
  }) {
    return Column(
      children: [
        Text(
          top,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          bottom,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foregroundColor.withOpacity(0.62),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
