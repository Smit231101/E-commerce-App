import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/layers/data/models/cart_item_model.dart';
import 'package:e_commerce_app/layers/presentation/cart/viewmodels/cart_view_model.dart';
import 'package:e_commerce_app/layers/presentation/home/screen/product_search_delegate.dart';
import 'package:e_commerce_app/layers/presentation/home/view_models/home_view_model.dart';
import 'package:e_commerce_app/layers/presentation/wishlist/viewmodel/wishlist_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/product_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        centerTitle: true,
        title: Text(
          'DISCOVER',
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.primary,
            fontSize: 14,
            letterSpacing: 8.0,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.tune_rounded,
            color: scheme.primary.withOpacity(0.92),
          ),
          onPressed: () {
            // Filter logic
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.outline.withOpacity(0.16)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: scheme.primary.withOpacity(0.92),
                size: 20,
              ),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ProductSearchDelegate(
                    viewModel: context.read<HomeViewModel>(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return _buildShimmerGrid(context);
          }
          if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          }
          if (viewModel.products.isEmpty) {
            return const Center(child: Text('No products available.'));
          }

          final categories = viewModel.categories;

          return DefaultTabController(
            length: categories.length,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  dividerColor: scheme.surface.withOpacity(0),
                  indicator: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: scheme.onPrimary,
                  unselectedLabelColor: scheme.onSurface.withOpacity(0.62),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                  tabs: categories.map((category) {
                    return Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(category.toUpperCase()),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: categories.map((category) {
                      final categoryProducts = viewModel.getProductsByCategory(
                        category,
                      );
                      return _buildProductGrid(context, categoryProducts);
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseColor = Color.alphaBlend(
      scheme.primary.withOpacity(0.06),
      scheme.surface,
    );
    final highlightColor = Color.alphaBlend(
      scheme.secondary.withOpacity(0.12),
      scheme.surface,
    );

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 20,
        mainAxisSpacing: 24,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(BuildContext context, List<ProductModel> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No items in this category.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _ProductCard(product: products[index]);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cardShadow = scheme.primary.withOpacity(
      theme.brightness == Brightness.dark ? 0.18 : 0.06,
    );
    final imagePanelColor = Color.alphaBlend(
      scheme.primary.withOpacity(
        theme.brightness == Brightness.dark ? 0.10 : 0.04,
      ),
      scheme.surface,
    );

    return GestureDetector(
      onTap: () => context.push('/product-detail', extra: product),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: cardShadow,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: imagePanelColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Hero(
                          tag: 'product_image_${product.id}',
                          child: CachedNetworkImage(
                            imageUrl: product.thumbnail,
                            fit: BoxFit.contain,
                            progressIndicatorBuilder:
                                (context, url, progress) => Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: scheme.primary.withOpacity(0.28),
                                  ),
                                ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.broken_image_rounded,
                              color: scheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: scheme.surface.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          onTap: () async {
                            final wishlistVM = context
                                .read<WishlistViewModel>();
                            // 1. Tell the ViewModel to toggle the state
                            await wishlistVM.toggleFavorite(product);

                            // 2. We use context.mounted to ensure the screen is still visible
                            // after the async toggle before showing the SnackBar
                            if (!context.mounted) return;

                            // 3. Clear any currently showing SnackBars so they don't queue up
                            // if the user taps the button 5 times really fast!
                            ScaffoldMessenger.of(context).clearSnackBars();

                            // 4. Determine the correct message
                            final bool isNowFavorited = wishlistVM.isFavorite(
                              product.id,
                            );
                            final String message = isNowFavorited
                                ? '${product.title} added to Wishlist'
                                : '${product.title} removed from Wishlist';

                            // 5. Show the Premium SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  message,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                behavior: SnackBarBehavior
                                    .floating, // Makes it float above the bottom navigation bar
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ), // Sleek rounded edges
                                ),
                                duration: const Duration(
                                  seconds: 2,
                                ), // Quick display so it doesn't linger
                                action: SnackBarAction(
                                  label: 'VIEW',
                                  textColor: Theme.of(context)
                                      .colorScheme
                                      .secondary, // Champagne Gold accent
                                  onPressed: () {
                                    // Optional: Navigate straight to the Wishlist tab if they tap VIEW
                                    // For go_router with StatefulShellRoute, this depends on your tab index setup,
                                    // but generally context.go('/wishlist') works if configured!
                                  },
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.favorite_border_rounded,
                            size: 20,
                            color: scheme.primary.withOpacity(0.92),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: scheme.secondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${(product.price * 93.26).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: scheme.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: () async {
                                final cartViewModel = context
                                    .read<CartViewModel>();
                                final cartItem = CartItemModel(
                                  productId: product.id,
                                  title: product.title,
                                  price: product.price,
                                  thumbnail: product.thumbnail,
                                );

                                try {
                                  await cartViewModel.addItem(cartItem);
                                  if (!context.mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${product.title} added to cart.',
                                      ),
                                    ),
                                  );
                                } catch (_) {
                                  if (!context.mounted) {
                                    return;
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to add item to cart.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Icon(
                                Icons.add,
                                color: scheme.onPrimary,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
