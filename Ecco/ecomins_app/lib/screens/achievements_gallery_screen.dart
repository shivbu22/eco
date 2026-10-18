import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AchievementsGalleryScreen extends StatelessWidget {
  const AchievementsGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
        ),
        title: const Text('Impact Trophies', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score Board
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  const Text('Total Eco-Points', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text('12,450', style: TextStyle(color: AppColors.primary, fontSize: 48, fontWeight: FontWeight.w900, shadows: [Shadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 20)])),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                    child: const Text('GLOBAL GUARDIAN', style: TextStyle(color: AppColors.onSurface, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildBadge(
                  icon: Icons.park,
                  title: 'First Recycling',
                  isUnlocked: true,
                  isActive: true, // Tapped State
                  message: 'You saved 5kg of CO2 this month!',
                ),
                _buildBadge(
                  icon: Icons.electric_bolt,
                  title: 'Zero Waste Week',
                  isUnlocked: true,
                ),
                _buildBadge(
                  icon: Icons.co2,
                  title: 'Carbon Offsetter',
                  isUnlocked: true,
                ),
                _buildBadge(
                  icon: Icons.water_drop,
                  title: 'Ocean Guardian',
                  isUnlocked: false,
                ),
                _buildBadge(
                  icon: Icons.wb_sunny,
                  title: 'Solar Pioneer',
                  isUnlocked: false,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String title, required bool isUnlocked, bool isActive = false, String? message}) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.surfaceContainerLow : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.primary : (isUnlocked ? AppColors.primary.withValues(alpha: 0.2) : AppColors.outlineVariant.withValues(alpha: 0.2)),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20)] : [],
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUnlocked ? AppColors.primary.withValues(alpha: isActive ? 0.2 : 0.1) : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    boxShadow: (isUnlocked && isActive) ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 15)] : [],
                  ),
                  child: Icon(
                    icon, 
                    color: isUnlocked ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.4), 
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title, 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isUnlocked ? AppColors.onSurface : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (!isUnlocked)
            Positioned(
              top: 12, right: 12,
              child: Icon(Icons.lock, color: AppColors.onSurfaceVariant.withValues(alpha: 0.3), size: 14),
            ),
          if (isActive && message != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                      const SizedBox(height: 8),
                      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
