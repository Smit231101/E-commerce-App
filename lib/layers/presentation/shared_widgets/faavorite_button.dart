import 'package:e_commerce_app/layers/presentation/wishlist/viewmodel/wishlist_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/product_model.dart';

class FavoriteButton extends StatelessWidget {
  final ProductModel product;

  const FavoriteButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // 1. The Consumer looks up the widget tree to find your ViewModel
    return Consumer<WishlistViewModel>(
      // 2. THIS is where wishlistVM is defined! Provider passes it into this builder function.
      builder: (context, wishlistVM, child) { 
        
        final isFavorited = wishlistVM.isFavorite(product.id);

        return IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_outline,
              key: ValueKey(isFavorited),
              color: isFavorited ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
            ),
          ),
          onPressed: () async {
            // 3. Now you can use it perfectly here!
            await wishlistVM.toggleFavorite(product);
            
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).clearSnackBars();

            final bool isNowFavorited = wishlistVM.isFavorite(product.id);
            final String message = isNowFavorited 
                ? '${product.title} added to Wishlist' 
                : '${product.title} removed from Wishlist';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message,
                  style: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.w500),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}