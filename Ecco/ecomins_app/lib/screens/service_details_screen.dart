import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'booking_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'OZOMIN',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Row(
              children: [
                const Text(
                  'DEEP ',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'CLEAN',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Professional grade sanitation using plant-based enzymatic agents.',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Select Areas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('SELECT AREAS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('4 Available', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildAreaCard(Icons.kitchen, 'Kitchen', 'Includes appliances', false),
                _buildAreaCard(Icons.bathtub, 'Bathroom', 'Sanitation focus', false),
                _buildAreaCard(Icons.weekend, 'Living', 'Dust & upholstery', true),
                _buildAreaCard(Icons.home, 'Full Home', 'Ultimate refresh', false),
              ],
            ),
            const SizedBox(height: 32),

            // Specialists Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('CLEANING SPECIALISTS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('See All', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, decoration: TextDecoration.underline)),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildSpecialistCard('Marcus Chen', '4.9', '124 jobs', 'Kitchen Expert'),
                  const SizedBox(width: 16),
                  _buildSpecialistCard('Elena Vance', '5.0', '89 jobs', 'Eco-Pro', isFeatured: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Cost Summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('COST SUMMARY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 2.0)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Deep Clean (Living)', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                      Text('\$85.00', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Bio-Agent Surcharge', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                      Text('+\$0.00 (Free)', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.energy_savings_leaf, color: AppColors.primary, size: 16),
                            SizedBox(width: 8),
                            Text('Eco-Credit Applied', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text('-\$15.00', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.outlineVariant),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Total Payable', style: TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('\$70.00', style: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // FAB spacing
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingScreen()));
        },
        label: Row(
          children: const [
            Icon(Icons.calendar_today, color: AppColors.onPrimary, size: 20),
            SizedBox(width: 8),
            Text('SCHEDULE NOW', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaCard(IconData icon, String title, String subtitle, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.05), width: isSelected ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSpecialistCard(String name, String rating, String jobs, String badge, {bool isFeatured = false}) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFeatured ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isFeatured ? AppColors.primary.withValues(alpha: 0.3) : AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('($jobs)', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(badge, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ),
        ],
      ),
    );
  }
}
