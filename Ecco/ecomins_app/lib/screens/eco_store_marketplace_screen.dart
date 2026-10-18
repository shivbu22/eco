import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EcoStoreMarketplaceScreen extends StatelessWidget {
  const EcoStoreMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
        ),
        title: const Text('EcoStore', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.onSurface)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search zero-waste products...',
                        hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Categories
            const Text('Categories', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildCategoryChip('Home Goods', isSelected: true),
                  _buildCategoryChip('Personal Care'),
                  _buildCategoryChip('Kitchen'),
                  _buildCategoryChip('Apparel'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Products Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Popular Products', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('See All', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.75,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildProductCard('Bamboo Toothbrush Set', '4-Pack Biodegradable', '\$12.00', 'assets/image1.jpg'),
                _buildProductCard('Reusable Produce Bags', 'Organic Cotton', '\$18.50', 'assets/image2.jpg'),
                _buildProductCard('Beeswax Food Wrap', 'Assorted Sizes', '\$22.00', 'assets/image3.jpg'),
                _buildProductCard('Glass Compost Bin', 'Odor-Free Filter', '\$45.00', 'assets/image4.jpg'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.background : AppColors.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildProductCard(String title, String subtitle, String price, String imgPlaceholder) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: AppColors.surfaceContainerHighest,
              width: double.infinity,
              child: const Icon(Icons.image_outlined, color: AppColors.onSurfaceVariant, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(price, style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w900)),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: AppColors.background, size: 16),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
