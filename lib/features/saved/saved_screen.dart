import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/services/product_service.dart';
import '../../core/services/saved_service.dart';
import '../../models/product_model.dart';

class SavedScreen extends StatelessWidget {
  final bool embeddedInNav;
  const SavedScreen({super.key, this.embeddedInNav = false});

  void _openProduct(BuildContext context, ProductModel product) {
    final route = switch (product.kind) {
      ProductKind.fastFood => AppRoutes.productDetail,
      ProductKind.tiffinMeal => AppRoutes.tiffinDetail,
      ProductKind.spice => AppRoutes.spiceDetail,
    };
    Navigator.pushNamed(context, route, arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: embeddedInNav
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Saved Items',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: SavedService.instance,
          builder: (context, _) {
            final savedIds = SavedService.instance.savedIds;

            return StreamBuilder<List<ProductModel>>(
              stream: ProductService.instance.getAllProductsWithFallback(),
              builder: (context, snapshot) {
                final allProducts = snapshot.data ?? const <ProductModel>[];
                final savedProducts = allProducts
                    .where((product) => savedIds.contains(product.id))
                    .toList();

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (embeddedInNav)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Saved Items',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      if (!snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.waiting)
                        const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (savedProducts.isEmpty)
                        Expanded(
                          child: _EmptySavedState(embeddedInNav: embeddedInNav),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: savedProducts.length,
                            itemBuilder: (context, index) {
                              final product = savedProducts[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteSurface,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: ListTile(
                                  onTap: () => _openProduct(context, product),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  leading: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: _accentFor(
                                        product.kind,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      product.emoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                  title: Text(
                                    product.name,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      product.subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () => SavedService.instance
                                            .remove(product.id),
                                        icon: const Icon(
                                          Icons.favorite_rounded,
                                          color: AppColors.primaryRed,
                                        ),
                                      ),
                                      Text(
                                        '₹${product.price.toStringAsFixed(0)}',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w800,
                                          color: _accentFor(product.kind),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _accentFor(ProductKind kind) {
    return switch (kind) {
      ProductKind.fastFood => AppColors.primaryRed,
      ProductKind.tiffinMeal => AppColors.primaryOrange,
      ProductKind.spice => AppColors.primaryBrown,
    };
  }
}

class _EmptySavedState extends StatelessWidget {
  const _EmptySavedState({required this.embeddedInNav});

  final bool embeddedInNav;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!embeddedInNav) const Spacer(),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              size: 64,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No saved items yet',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart on product details to build your favorites list.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.bottomNav,
              (route) => false,
              arguments: 0,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Explore Menu',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            ),
          ),
          if (!embeddedInNav) const Spacer(),
        ],
      ),
    );
  }
}
