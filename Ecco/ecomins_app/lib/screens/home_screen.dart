import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'booking_screen.dart';
import 'notifications_screen.dart';
import 'eco_tips_screen.dart';
import 'promotions_screen.dart';
import 'service_gallery_screen.dart';
import 'seasonal_challenges_screen.dart';
import 'all_categories_screen.dart';
import 'worker_profile_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = _db.getServiceCatalogSync();
    final workers = _db.getTopWorkers();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0C), // Pure dark background from image
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildSearchBar(context)),
            SliverToBoxAdapter(child: _buildHeroBanner(context)),
            SliverToBoxAdapter(child: _buildActiveWorkersBadge()),
            SliverToBoxAdapter(child: _buildImpactCard(context)),
            SliverToBoxAdapter(child: _buildDailyTipBanner(context)),
            _buildSectionTitle('OZOMIN Services', null),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, idx) => _buildServiceCard(context, services[idx], idx),
                  childCount: services.length,
                ),
              ),
            ),
            _buildSectionTitle('Top OZOMIN Pros', 'VIEW ALL'),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: workers.length,
                  itemBuilder: (context, idx) {
                    return _buildWorkerTile(workers[idx], idx);
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildFadeSlide({required Widget child, required double delay}) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, childWidget) {
        final curve = CurvedAnimation(
            parent: _animController,
            curve: Interval(delay, 1.0, curve: Curves.easeOutCubic));
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curve.value)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return _buildFadeSlide(
      delay: 0.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF00E676),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('O',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OZOMIN',
                      style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                  Row(
                    children: [
                      const Text('Koramangala, BLR',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white.withValues(alpha: 0.6), size: 16),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen())),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.0)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.notifications_rounded,
                        color: Colors.white70, size: 22),
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF1E1E1E), width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return _buildFadeSlide(
      delay: 0.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.5), size: 20),
              const SizedBox(width: 12),
              Text(
                'Find OZOMIN eco services...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactCard(BuildContext context) {
    return _buildFadeSlide(
      delay: 0.15,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D1F13), Color(0xFF14301B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Eco Impact',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '45 kg CO₂',
                    style: TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Reduced this month',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Color(0xFF00E676),
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTipBanner(BuildContext context) {
    return _buildFadeSlide(
      delay: 0.2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EcoTipsScreen())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Color(0xFFFFD54F),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Daily Eco Tip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Unplug unused chargers to save energy today.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Explore More row
            Row(
              children: [
                _ExploreChip(
                  icon: Icons.local_offer_rounded,
                  label: 'Offers',
                  color: const Color(0xFFFF8A65),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PromotionsScreen())),
                ),
                const SizedBox(width: 10),
                _ExploreChip(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: const Color(0xFF64B5F6),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceGalleryScreen())),
                ),
                const SizedBox(width: 10),
                _ExploreChip(
                  icon: Icons.emoji_events_rounded,
                  label: 'Challenges',
                  color: const Color(0xFFFFD54F),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SeasonalChallengesScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return _buildFadeSlide(
      delay: 0.2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F1A12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF1B3D23),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Leaf Graphic in bottom right
              Positioned(
                right: -30,
                bottom: -40,
                child: Opacity(
                  opacity: 0.5,
                  child: Transform.rotate(
                    angle: -math.pi / 6,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 160,
                      color: const Color(0xFF16321C),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12351A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.bolt,
                              color: Color(0xFF00E676), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'HYPER-LOCAL SPEED',
                            style: TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Eco services in\n10 minutes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Instant booking for verified\nOZOMIN cleaning & recycling\nexperts.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BookingScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'BOOK NOW',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveWorkersBadge() {
    return _buildFadeSlide(
      delay: 0.25,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '24 ACTIVE WORKERS NEARBY',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? actionText) {
    return SliverToBoxAdapter(
      child: _buildFadeSlide(
        delay: 0.3,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              if (actionText != null)
                TextButton(
                  onPressed: () {
                    if (actionText == 'View All') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AllCategoriesScreen()));
                    }
                  },
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, Map<String, dynamic> service, int idx) {
    return _buildFadeSlide(
      delay: 0.35 + (idx * 0.05),
      child: BouncingWidget(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingScreen(initialService: service),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (service.containsKey('image'))
                Image.asset(
                  service['image'] as String,
                  fit: BoxFit.cover,
                )
              else
                Container(color: const Color(0xFF1C1C1C)),
              if (service.containsKey('image'))
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.7),
                        const Color(0xFF1C1C1C).withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!service.containsKey('image'))
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF122C1A),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _getIconForEmoji(service['emoji'] as String),
                            color: const Color(0xFF00E676),
                            size: 18,
                          ),
                        ),
                      ),
                    if (service.containsKey('image'))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconForEmoji(service['emoji'] as String),
                              color: const Color(0xFF00E676),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service['category']?.toString().toUpperCase() ?? 'ECO',
                              style: const TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
              Text(
                service['title'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    service['price'] == 0 ? 'FREE' : '₹${(service['price'] as double).toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (service['price'] != 0)
                    Text(
                      ' /hr',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForEmoji(String emoji) {
    if (emoji == '🧹') return Icons.cleaning_services_rounded;
    if (emoji == '♻️') return Icons.recycling_rounded;
    if (emoji == '💧') return Icons.water_drop_rounded;
    if (emoji == '☀️') return Icons.solar_power_rounded;
    if (emoji == '🗑️') return Icons.delete_outline_rounded;
    if (emoji == '🌱') return Icons.energy_savings_leaf_rounded;
    if (emoji == '🗃️') return Icons.inventory_2_rounded;
    if (emoji == '🚛') return Icons.local_shipping_rounded;
    if (emoji == '✨') return Icons.auto_awesome_rounded;
    if (emoji == '🔒') return Icons.security_rounded;
    if (emoji == '🪣') return Icons.wash_rounded;
    if (emoji == '🌬️') return Icons.air_rounded;
    if (emoji == '🪴') return Icons.yard_rounded;
    return Icons.eco_rounded;
  }

  Widget _buildWorkerTile(Map<String, dynamic> worker, int idx) {
    return _buildFadeSlide(
      delay: 0.4 + (idx * 0.1),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00E676),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      worker['avatar'] as String,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${worker['rating']}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.star, color: Colors.black, size: 8),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text(
              worker['name'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              worker['speciality'] as String,
              style: const TextStyle(
                color: Color(0xFF00E676),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkerProfileScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'BOOK',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BouncingWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BouncingWidget({super.key, required this.child, required this.onTap});

  @override
  State<BouncingWidget> createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class _ExploreChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExploreChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
