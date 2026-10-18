import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ServiceGalleryScreen extends StatefulWidget {
  const ServiceGalleryScreen({super.key});

  @override
  State<ServiceGalleryScreen> createState() => _ServiceGalleryScreenState();
}

class _ServiceGalleryScreenState extends State<ServiceGalleryScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Cleaning', 'Garden', 'Solar', 'Recycling'];

  final List<Map<String, dynamic>> _gallery = [
    {
      'serviceName': 'Eco Deep Cleaning',
      'beforeImage': 'assets/images/deep_clean.png',
      'afterImage': 'assets/images/eco_cleaning.png',
      'rating': 4.9,
      'reviews': 238,
      'category': 'Cleaning',
      'provider': 'GreenClean Co.',
    },
    {
      'serviceName': 'Garden Transformation',
      'beforeImage': 'assets/images/garden_care.png',
      'afterImage': 'assets/images/smart_compost.png',
      'rating': 4.8,
      'reviews': 156,
      'category': 'Garden',
      'provider': 'EcoGarden India',
    },
    {
      'serviceName': 'Solar Panel Care',
      'beforeImage': 'assets/images/solar_cleaning.png',
      'afterImage': 'assets/images/air_purifier.png',
      'rating': 5.0,
      'reviews': 92,
      'category': 'Solar',
      'provider': 'SolarShine',
    },
    {
      'serviceName': 'Recycling Pickup',
      'beforeImage': 'assets/images/recycling_pickup.png',
      'afterImage': 'assets/images/garbage_collection.png',
      'rating': 4.7,
      'reviews': 312,
      'category': 'Recycling',
      'provider': 'CleanSort',
    },
    {
      'serviceName': 'Water Tank Cleaning',
      'beforeImage': 'assets/images/water_tank.png',
      'afterImage': 'assets/images/homeguard.png',
      'rating': 4.6,
      'reviews': 189,
      'category': 'Cleaning',
      'provider': 'AquaPure',
    },
    {
      'serviceName': 'Bulk Waste Removal',
      'beforeImage': 'assets/images/bulk_waste.png',
      'afterImage': 'assets/images/sweeper.png',
      'rating': 4.5,
      'reviews': 201,
      'category': 'Recycling',
      'provider': 'GreenHaul',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 0) return _gallery;
    return _gallery.where((g) => g['category'] == _filters[_selectedFilter]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: Padding(
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
                    const Expanded(
                      child: Text(
                        'Service Gallery',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${_gallery.length} Projects',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            // Filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filters.length,
                  itemBuilder: (ctx, i) {
                    final active = _selectedFilter == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? AppColors.primary : AppColors.outlineVariant,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _filters[i],
                          style: TextStyle(
                            color: active ? Colors.black : Colors.white60,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            // Gallery grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _GalleryCard(item: _filtered[i]),
                  childCount: _filtered.length,
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

class _GalleryCard extends StatefulWidget {
  final Map<String, dynamic> item;

  const _GalleryCard({required this.item});

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  bool _showAfter = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with before/after toggle
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Image.asset(
                    _showAfter ? item['afterImage'] : item['beforeImage'],
                    key: ValueKey(_showAfter),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 200,
                      color: AppColors.surfaceContainerLow,
                      child: Icon(Icons.image, size: 50, color: Colors.white.withValues(alpha: 0.2)),
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Before/After toggle
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _showAfter = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: !_showAfter ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Before',
                              style: TextStyle(
                                color: !_showAfter ? Colors.black : Colors.white60,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _showAfter = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _showAfter ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'After',
                              style: TextStyle(
                                color: _showAfter ? Colors.black : Colors.white60,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item['category'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['serviceName'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'by ${item['provider']}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${item['rating']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      ' (${item['reviews']} reviews)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
