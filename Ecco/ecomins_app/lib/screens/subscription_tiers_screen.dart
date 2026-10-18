import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SubscriptionTiersScreen extends StatelessWidget {
  const SubscriptionTiersScreen({super.key});

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
        title: const Text('Eco Memberships', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose Your Impact',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a monthly tier to offset your carbon footprint and unlock exclusive Eco-Services.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 32),
            _buildTierCard(
              title: 'Seedling',
              price: '\$4.99/mo',
              features: ['Offset 50kg CO2/mo', 'Basic Recycling Tips', '5% EcoStore Discount'],
              color: AppColors.outlineVariant,
              isActive: false,
            ),
            const SizedBox(height: 20),
            _buildTierCard(
              title: 'Canopy',
              price: '\$14.99/mo',
              features: ['Offset 200kg CO2/mo', 'Free Monthly Bulk Pickup', '15% EcoStore Discount', 'Vote on Green Projects'],
              color: AppColors.primary,
              isActive: true,
            ),
            const SizedBox(height: 20),
            _buildTierCard(
              title: 'Biosphere',
              price: '\$29.99/mo',
              features: ['Carbon Neutral Life', 'Priority Eco-Services', '25% EcoStore Discount', 'Dedicated Green Concierge'],
              color: AppColors.tertiary,
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard({required String title, required String price, required List<String> features, required Color color, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? color : color.withValues(alpha: 0.3),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: isActive ? color : AppColors.onSurface, fontSize: 22, fontWeight: FontWeight.bold)),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Text('CURRENT', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                )
            ],
          ),
          const SizedBox(height: 8),
          Text(price, style: const TextStyle(color: AppColors.onSurface, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(f, style: const TextStyle(color: AppColors.onSurface, fontSize: 14))),
              ],
            ),
          )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? AppColors.surfaceContainerHighest : color,
                foregroundColor: isActive ? color : AppColors.background,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {},
              child: Text(isActive ? 'Manage Plan' : 'Select Tier', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
