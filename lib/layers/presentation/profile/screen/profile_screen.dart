import 'package:e_commerce_app/layers/presentation/auth/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final heroCardColor = isDark ? scheme.surface : scheme.primary;
    final heroForeground = isDark ? scheme.onSurface : scheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        centerTitle: true,
        title: Text(
          'MY ACCOUNT',
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.primary,
            fontSize: 13,
            letterSpacing: 4.0,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Consumer<AuthViewmodel>(
        builder: (context, authViewModel, child) {
          if (!authViewModel.isLoggedIn) {
            return _buildLoggedOutState(context);
          }

          if (authViewModel.isProfileLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: scheme.primary,
                strokeWidth: 2,
              ),
            );
          }

          if (authViewModel.profileErrorMessage != null) {
            return _buildProfileMessageState(
              context,
              icon: Icons.error_outline_rounded,
              title: 'Unable to Load',
              message: authViewModel.profileErrorMessage!,
            );
          }

          if (authViewModel.userProfile == null) {
            return _buildProfileMessageState(
              context,
              icon: Icons.person_off_outlined,
              title: 'Profile Missing',
              message:
                  'Your account exists, but we could not fetch your details.',
            );
          }

          final profile = authViewModel.userProfile!;
          final initials =
              '${_firstLetter(profile.name)}${_firstLetter(profile.surname)}'
                  .toUpperCase();
          final fullName = [
            profile.name.trim(),
            profile.surname.trim(),
          ].where((part) => part.isNotEmpty).join(' ');

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: heroCardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withOpacity(isDark ? 0.24 : 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: heroForeground.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor:
                              isDark ? scheme.primary : scheme.surface,
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: isDark ? scheme.onPrimary : scheme.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: heroForeground,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              profile.email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: heroForeground.withOpacity(0.68),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: heroForeground.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: heroForeground,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                  child: Text(
                    'DASHBOARD',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface.withOpacity(0.5),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withOpacity(isDark ? 0.12 : 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildPremiumMenuTile(
                        context,
                        Icons.shopping_bag_outlined,
                        'My Orders',
                        isTop: true,
                      ),
                      _buildDivider(context),
                      _buildPremiumMenuTile(
                        context,
                        Icons.location_on_outlined,
                        'Shipping Addresses',
                      ),
                      _buildDivider(context),
                      _buildPremiumMenuTile(
                        context,
                        Icons.payment_outlined,
                        'Payment Methods',
                      ),
                      _buildDivider(context),
                      _buildPremiumMenuTile(
                        context,
                        Icons.favorite_border_rounded,
                        'Wishlist',
                        isBottom: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                  child: Text(
                    'PREFERENCES',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface.withOpacity(0.5),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withOpacity(isDark ? 0.12 : 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildPremiumMenuTile(
                        context,
                        Icons.settings_outlined,
                        'Settings',
                        isTop: true,
                      ),
                      _buildDivider(context),
                      _buildPremiumMenuTile(
                        context,
                        Icons.help_outline_rounded,
                        'Help & Support',
                        isBottom: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: scheme.error.withOpacity(0.10),
                      foregroundColor: scheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => authViewModel.logout(),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumMenuTile(
    BuildContext context,
    IconData icon,
    String title, {
    bool isTop = false,
    bool isBottom = false,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final iconContainerColor = Color.alphaBlend(
      scheme.primary.withOpacity(0.05),
      scheme.surface,
    );

    return InkWell(
      onTap: () {
        // Navigation logic here
      },
      borderRadius: BorderRadius.vertical(
        top: isTop ? const Radius.circular(24) : Radius.zero,
        bottom: isBottom ? const Radius.circular(24) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconContainerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: scheme.onSurface.withOpacity(0.28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 68.0, right: 20.0),
      child: Divider(color: Theme.of(context).dividerColor),
    );
  }

  Widget _buildLoggedOutState(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: scheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.lock_person_outlined,
                size: 64,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Exclusive Access',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to view your personalized dashboard, track orders, and curate your wishlist.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withOpacity(0.62),
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => context.push('/login'),
                child: const Text(
                  'SIGN IN / REGISTER',
                  style: TextStyle(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMessageState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: scheme.primary.withOpacity(0.26)),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withOpacity(0.62),
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _firstLetter(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return "";
    }
    return trimmed[0];
  }
}
