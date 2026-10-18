import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'search_results_screen.dart'; // We can pretend tapping a category searches it.

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.cleaning_services_rounded, 'label': 'Deep Clean', 'color': Colors.blue},
      {'icon': Icons.yard_rounded, 'label': 'Eco Garden', 'color': Colors.green},
      {'icon': Icons.recycling_rounded, 'label': 'Zero Waste', 'color': Colors.orange},
      {'icon': Icons.solar_power_rounded, 'label': 'Solar Care', 'color': Colors.yellow},
      {'icon': Icons.water_drop_rounded, 'label': 'Water Fix', 'color': Colors.cyan},
      {'icon': Icons.electric_bolt_rounded, 'label': 'Energy', 'color': Colors.amber},
      {'icon': Icons.eco_rounded, 'label': 'Composting', 'color': Colors.lightGreen},
      {'icon': Icons.handyman_rounded, 'label': 'Upcycle', 'color': Colors.purple},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'All Eco Services',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explore Solutions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a category to find verified eco-warriors dedicated to restoring the harmony of your home and planet.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return _buildCategoryCard(
                    context,
                    icon: cat['icon'] as IconData,
                    label: cat['label'] as String,
                    baseColor: cat['color'] as Color,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, {required IconData icon, required String label, required Color baseColor}) {
    return GestureDetector(
      onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchResultsScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: baseColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
