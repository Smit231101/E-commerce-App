import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce_app/layers/data/models/cart_item_model.dart';
import 'package:e_commerce_app/layers/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:e_commerce_app/layers/presentation/cart/viewmodels/cart_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartViewState();
}

class _CartViewState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'YOUR BAG',
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.primary,
            fontSize: 18,
            letterSpacing: 3.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CartViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.cartItems.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: scheme.primary),
            );
          }

          if (viewModel.cartItems.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: viewModel.cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final item = viewModel.cartItems[index];
                    return _buildCartItem(context, item, viewModel);
                  },
                ),
              ),
              _buildCheckoutBar(context, viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: scheme.primary.withOpacity(0.18),
          ),
          const SizedBox(height: 24),
          Text(
            'Your bag is empty.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: scheme.primary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover our latest collection.',
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurface.withOpacity(0.58),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItemModel item,
    CartViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final imagePanelColor = Color.alphaBlend(
      scheme.primary.withOpacity(
        theme.brightness == Brightness.dark ? 0.12 : 0.04,
      ),
      scheme.surface,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Dismissible(
        key: ValueKey(item.productId),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => viewModel.removeItem(item.productId),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(
            color: scheme.error,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Delete',
                style: TextStyle(
                  color: scheme.onError,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.delete_sweep_rounded, color: scheme.onError, size: 24),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(
                  theme.brightness == Brightness.dark ? 0.16 : 0.05,
                ),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 85,
                height: 100,
                decoration: BoxDecoration(
                  color: imagePanelColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outline.withOpacity(0.12)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: item.thumbnail,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'In Stock • Ready to ship',
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurface.withOpacity(0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₹${(item.price * 93.26).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add, size: 16, color: scheme.onPrimary),
                      onPressed: () => viewModel.increaseQuantity(item),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimary,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.remove,
                        size: 16,
                        color: scheme.onPrimary.withOpacity(0.74),
                      ),
                      onPressed: () => viewModel.decreaseQuantity(item),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartViewModel viewModel) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final double subtotalInr = viewModel.subtotal * 93.26;
    final double taxInr = viewModel.tax * 93.26;
    final double totalInr = viewModel.total * 93.26;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(
              theme.brightness == Brightness.dark ? 0.20 : 0.07,
            ),
            blurRadius: 32,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: scheme.outline.withOpacity(0.22),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            _buildReceiptRow(context, 'Subtotal', subtotalInr),
            const SizedBox(height: 14),
            _buildReceiptRow(context, 'Estimated Tax', taxInr),
            const SizedBox(height: 24),
            Container(
              height: 1,
              width: double.infinity,
              color: scheme.outline.withOpacity(0.14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        color: scheme.onSurface.withOpacity(0.52),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${totalInr.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (viewModel.cartItems.isEmpty) return;
                    final isLoggedIn = context.read<AuthViewmodel>().isLoggedIn;
                    if (!isLoggedIn) {
                      context.push("/login");
                    } else {
                      context.push("/checkout");
                    }
                  },
                  child: Row(
                    children: [
                      const Text(
                        'CHECKOUT',
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: scheme.onPrimary.withOpacity(0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(BuildContext context, String label, double amount) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: scheme.onSurface.withOpacity(0.62),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
