import 'package:e_commerce_app/layers/presentation/home/view_models/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/product_model.dart';

class ProductSearchDelegate extends SearchDelegate<ProductModel?> {
  final HomeViewModel viewModel;

  ProductSearchDelegate({required this.viewModel});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
      ),
    );
  }

  // 2. The clear text button (right side of search bar)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
            query = ''; // Clears the text
          },
        ),
    ];
  }

  // 3. The back button (left side of search bar)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
      onPressed: () {
        close(context, null); // Closes the search screen
      },
    );
  }

  // 4. The final results when the user hits 'Enter'
  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  // 5. The live suggestions as the user types
  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  // --- PREMIUM SEARCH RESULT LIST ---
  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            const SizedBox(height: 24),
            Text(
              'Search for products or categories...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final results = viewModel.searchProducts(query);

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No results found for "$query"',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24.0),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Divider(height: 1, thickness: 0.5),
      ),
      itemBuilder: (context, index) {
        final product = results[index];
        return InkWell(
          onTap: () {
            close(context, null); // Close the search overlay
            context.push(
              '/product-detail',
              extra: product,
            ); // Navigate to details
          },
          child: Row(
            children: [
              // Tiny product thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: product.thumbnail,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Text Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
