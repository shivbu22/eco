import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'ancient_wisdom_screen.dart';

class EcoTipsScreen extends StatefulWidget {
  const EcoTipsScreen({super.key});

  @override
  State<EcoTipsScreen> createState() => _EcoTipsScreenState();
}

class _EcoTipsScreenState extends State<EcoTipsScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ['All', 'Water', 'Energy', 'Waste', 'Food'];

  final List<Map<String, dynamic>> _tips = [
    {
      'title': 'Switch to LED Bulbs',
      'description': 'LED bulbs use 75% less energy and last 25x longer than incandescent bulbs. A simple switch that saves ₹2,000+ per year.',
      'icon': Icons.lightbulb_outline,
      'color': Color(0xFFFFB74D),
      'category': 'Energy',
      'impact': '120 kg CO₂/year',
      'difficulty': 'Easy',
      'saved': false,
    },
    {
      'title': 'Fix Leaky Faucets',
      'description': 'A single dripping faucet can waste over 11,000 liters of water per year. Check and fix all taps in your home.',
      'icon': Icons.water_drop_outlined,
      'color': Color(0xFF64B5F6),
      'category': 'Water',
      'impact': '11,000 L/year',
      'difficulty': 'Easy',
      'saved': true,
    },
    {
      'title': 'Compost Kitchen Waste',
      'description': 'Start composting fruit peels, tea leaves, and vegetable scraps. Reduce landfill waste by 30% while creating nutrient-rich soil.',
      'icon': Icons.eco_rounded,
      'color': AppColors.primary,
      'category': 'Waste',
      'impact': '200 kg waste/year',
      'difficulty': 'Medium',
      'saved': false,
    },
    {
      'title': 'Unplug Standby Devices',
      'description': 'Devices on standby consume 5-10% of household energy. Unplug chargers, TVs, and computers when not in use.',
      'icon': Icons.power_outlined,
      'color': Color(0xFFFF8A65),
      'category': 'Energy',
      'impact': '90 kg CO₂/year',
      'difficulty': 'Easy',
      'saved': false,
    },
    {
      'title': 'Buy Local Produce',
      'description': 'Locally grown food travels less, meaning fewer carbon emissions. Visit your local farmer\'s market this weekend.',
      'icon': Icons.storefront_outlined,
      'color': Color(0xFF81C784),
      'category': 'Food',
      'impact': '150 kg CO₂/year',
      'difficulty': 'Easy',
      'saved': true,
    },
    {
      'title': 'Install Low-Flow Showerheads',
      'description': 'Low-flow showerheads reduce water usage by 40% without sacrificing pressure. Save water and your energy bill.',
      'icon': Icons.shower_outlined,
      'color': Color(0xFF4FC3F7),
      'category': 'Water',
      'impact': '15,000 L/year',
      'difficulty': 'Easy',
      'saved': false,
    },
    {
      'title': 'Start a Kitchen Garden',
      'description': 'Grow herbs and vegetables at home. Even a small balcony garden reduces food miles to zero and provides fresh produce.',
      'icon': Icons.grass_rounded,
      'color': Color(0xFF66BB6A),
      'category': 'Food',
      'impact': '50 kg CO₂/year',
      'difficulty': 'Medium',
      'saved': false,
    },
    {
      'title': 'Use Cloth Bags',
      'description': 'Replace single-use plastic bags with reusable cloth bags. One cloth bag replaces 700 plastic bags over its lifetime.',
      'icon': Icons.shopping_bag_outlined,
      'color': Color(0xFFBA68C8),
      'category': 'Waste',
      'impact': '700 bags/lifetime',
      'difficulty': 'Easy',
      'saved': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredTips {
    if (_selectedCategory == 0) return _tips;
    return _tips.where((t) => t['category'] == _categories[_selectedCategory]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with banner image
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.outlineVariant),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Eco Tips',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${_tips.where((t) => t['saved']).length} Saved',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Hero banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/eco_tips_banner.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: AppColors.surfaceContainer,
                                child: const Icon(Icons.eco, size: 60, color: AppColors.primary),
                              ),
                            ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.7),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            // Text overlay
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Daily Eco Tip',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Small changes,\nbig impact',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AncientWisdomScreen()));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Panchamahabhuta Wisdom',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                  Text(
                                    'Explore ancient Indian eco-science',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.secondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Category chips
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      itemBuilder: (ctx, i) {
                        final isActive = _selectedCategory == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = i),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive ? AppColors.primary : AppColors.outlineVariant,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _categories[i],
                              style: TextStyle(
                                color: isActive ? Colors.black : Colors.white60,
                                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Tips list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final tip = _filteredTips[i];
                    return _EcoTipCard(
                      tip: tip,
                      onToggleSave: () {
                        setState(() => tip['saved'] = !tip['saved']);
                      },
                    );
                  },
                  childCount: _filteredTips.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _EcoTipCard extends StatelessWidget {
  final Map<String, dynamic> tip;
  final VoidCallback onToggleSave;

  const _EcoTipCard({required this.tip, required this.onToggleSave});

  @override
  Widget build(BuildContext context) {
    final Color color = tip['color'];
    final bool saved = tip['saved'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tip['icon'], color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tip['category'],
                        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggleSave,
                child: Icon(
                  saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: saved ? AppColors.primary : Colors.white30,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            tip['description'],
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatChip(
                icon: Icons.eco_rounded,
                label: tip['impact'],
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              _StatChip(
                icon: Icons.speed_rounded,
                label: tip['difficulty'],
                color: tip['difficulty'] == 'Easy'
                    ? const Color(0xFF66BB6A)
                    : AppColors.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
