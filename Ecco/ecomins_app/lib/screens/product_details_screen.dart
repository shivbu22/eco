import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Header Image
          Container(
            height: 400,
            width: double.infinity,
            color: AppColors.surfaceContainerHighest,
            child: Icon(Icons.eco, size: 120, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconBtn(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                  _buildIconBtn(Icons.favorite_border, () {}),
                ],
              ),
            ),
          ),

          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 350),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: const Text('Bamboo Toothbrush Set', style: TextStyle(color: AppColors.onSurface, fontSize: 26, fontWeight: FontWeight.w900))),
                          Text('\$12.00', style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.tertiary, size: 18),
                          const SizedBox(width: 4),
                          const Text('4.8', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(' (124 reviews)', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('Description', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        'A completely biodegradable 4-pack of bamboo toothbrushes. With soft charcoal-infused bristles and a natural ergonomic handle, this set is perfect for replacing single-use plastics in your daily routine.',
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      const Text('Eco-Impact', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildImpactChip(Icons.recycling, '100% Biodegradable'),
                          const SizedBox(width: 12),
                          _buildImpactChip(Icons.forest, 'Sustainable Bamboo'),
                        ],
                      ),
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        color: AppColors.background,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {},
            child: const Text('Add to Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.onSurface, size: 20),
      ),
    );
  }

  Widget _buildImpactChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
