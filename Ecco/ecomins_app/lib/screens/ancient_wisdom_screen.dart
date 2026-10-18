import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AncientWisdomScreen extends StatelessWidget {
  const AncientWisdomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Panchamahabhuta',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ancient Wisdom.\nModern Ecology.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'In Indian philosophy, the universe is crafted from five fundamental elements (Panchamahabhuta). Healing the Earth means strictly respecting and restoring the balance of these forces—a concept scientifically validated by natural cycles.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildElementCard(
                  title: 'Prithvi (Earth)',
                  description: 'The foundation of life. Scientific soil regeneration mirrors the Vedic respect for Dharti Mata. Preventing chemical runoffs sustains the very ground we walk on.',
                  icon: Icons.terrain_rounded,
                  color: Colors.brown,
                ),
                _buildElementCard(
                  title: 'Jala (Water)',
                  description: 'The fluid of existence. Varuna, the deity of water, symbolizes purity. Modern rainwater harvesting and zero-waste cleaning preserve this critical hydrogen-oxygen balance.',
                  icon: Icons.water_drop_rounded,
                  color: Colors.blue,
                ),
                _buildElementCard(
                  title: 'Agni (Fire)',
                  description: 'The energy of transformation. Harnessing solar power is the modern invocation of Surya (Sun God), utilizing clean photons instead of burning fossil fuels.',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.orange,
                ),
                _buildElementCard(
                  title: 'Vayu (Air)',
                  description: 'The breath of life. Vayu purifies. By planting trees and reducing emissions, we actively reduce particulate matter (PM2.5), scientifically restoring the atmosphere.',
                  icon: Icons.air_rounded,
                  color: Colors.cyan,
                ),
                _buildElementCard(
                  title: 'Akasha (Space)',
                  description: 'The limitless void. Creating minimalist, zero-waste environments reflects the clarity of Akasha, minimizing our physical footprint and allowing nature to reclaim its space.',
                  icon: Icons.auto_awesome_rounded,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementCard({required String title, required String description, required IconData icon, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
