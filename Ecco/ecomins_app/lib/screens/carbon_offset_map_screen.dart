import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CarbonOffsetMapScreen extends StatelessWidget {
  const CarbonOffsetMapScreen({super.key});

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
        title: const Text('Global Impact', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Mock Map Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800&auto=format&fit=crop'), // Abstract satellite view
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(AppColors.background.withValues(alpha: 0.8), BlendMode.darken),
              ),
            ),
          ),
          
          // Map Pointers
          Positioned(top: 300, left: 100, child: _buildMapPin('Amazon Reforestation')),
          Positioned(top: 200, right: 80, child: _buildMapPin('Wind Farm, Nordic')),
          Positioned(top: 450, right: 120, child: _buildMapPin('Solar Grid, Sahara')),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, -10))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 24),
                  const Text('Your Contributions', style: TextStyle(color: AppColors.onSurface, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildProjectListTile('Amazon Reforestation', 'Brazil • 20 Trees Planted', Icons.park, AppColors.primary),
                        _buildProjectListTile('Nordic Wind Farm', 'Sweden • 450 kWh Clean Energy', Icons.air, Colors.blueAccent),
                        _buildProjectListTile('Sahara Solar Grid', 'Morocco • 1.2 tons CO2 offset', Icons.wb_sunny, AppColors.tertiary),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMapPin(String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          child: Text(label, style: const TextStyle(color: AppColors.onSurface, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 10)],
          ),
        )
      ],
    );
  }

  Widget _buildProjectListTile(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}
