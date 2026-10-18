import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/location_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/services_provider.dart';
import '../data/models/service_model.dart';
import '../data/models/booking_model.dart';
import '../components/shared_widgets.dart';
import 'service_detail_screen.dart';
import 'cart_screen.dart';
import 'live_tracking_screen.dart';
import 'notifications_screen.dart';
import 'search_results_screen.dart';

class QuickHomeScreen extends StatefulWidget {
  const QuickHomeScreen({super.key});

  @override
  State<QuickHomeScreen> createState() => _QuickHomeScreenState();
}

class _QuickHomeScreenState extends State<QuickHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final location = context.watch<LocationProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    final servicesProvider = context.watch<ServicesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── TOP BAR: Location + Notifications ───────
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _buildTopBar(location),
                  ),
                ),
              ),

              // ─── GREETING ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning, Arjun',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'What can we help you with today?',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── SEARCH BAR ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _buildSearchBar(servicesProvider),
                ),
              ),

              // ─── ACTIVE ORDER CARD ───────────────────────
              if (bookingProvider.hasActiveBooking)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildActiveOrderCard(bookingProvider.activeBooking!),
                  ),
                ),

              // ─── FEATURED BANNER ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildUrgencyBanner(),
                ),
              ),

              // ─── CATEGORY PILLS ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                  child: _buildCategoryPills(servicesProvider),
                ),
              ),

              // ─── QUICK REORDER ───────────────────────────
              if (bookingProvider.lastCompletedBooking != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _buildQuickReorder(
                        bookingProvider.lastCompletedBooking!, servicesProvider),
                  ),
                ),

              // ─── POPULAR SERVICES ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Popular near you',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${servicesProvider.serviceCount} services',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── SERVICE GRID ────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.72, // Compact 3-column grid
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final service = servicesProvider.services[index];
                      return _buildServiceCard(service, cart);
                    },
                    childCount: servicesProvider.services.length,
                  ),
                ),
              ),
            ],
          ),

          // ─── FLOATING CART BAR ─────────────────────────
          if (cart.isNotEmpty) _buildCartBar(cart),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // TOP BAR
  // ════════════════════════════════════════════════════════
  Widget _buildTopBar(LocationProvider location) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showAddressPicker(context),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.onSurfaceVariant,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            location.areaName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                      Text(
                        location.displayLocation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildIconButton(
          Icons.notifications_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          badge: 3,
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon,
      {VoidCallback? onTap, int badge = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.onSurface, size: 18),
            if (badge > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // SEARCH BAR
  // ════════════════════════════════════════════════════════
  Widget _buildSearchBar(ServicesProvider provider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SearchResultsScreen(initialQuery: _searchController.text),
          ),
        );
      },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _searchController.text.isEmpty ? 'Search for eco services...' : _searchController.text,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: _searchController.text.isEmpty ? 0.5 : 0.9),
                  fontSize: 13,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    provider.search('');
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ACTIVE ORDER CARD
  // ════════════════════════════════════════════════════════
  Widget _buildActiveOrderCard(BookingModel booking) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LiveTrackingScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            // Service image placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: booking.serviceImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        booking.serviceImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Icon(Icons.eco_outlined, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.eco_outlined, color: AppColors.onSurfaceVariant),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(
                    text: booking.statusDisplay,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking.serviceName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (booking.workerName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${booking.workerName} • ${booking.etaMinutes ?? '~'} min away',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // FEATURED BANNER
  // ════════════════════════════════════════════════════════
  Widget _buildUrgencyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'FEATURED',
                    style: TextStyle(
                      color: AppColors.tertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Home deep clean',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Professional eco cleaning from ₹499',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Book',
              style: TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // CATEGORY PILLS
  // ════════════════════════════════════════════════════════
  Widget _buildCategoryPills(ServicesProvider provider) {
    final categories = ServicesProvider.categories;
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = index == _selectedCategoryIndex;
          
          // Remove emoji from label if we want clean text
          // The current data model mixes emojis and text, we can just use the label.
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategoryIndex = index);
                provider.selectCategory(cat['label'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  cat['label'] as String,
                  style: TextStyle(
                    color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // QUICK REORDER
  // ════════════════════════════════════════════════════════
  Widget _buildQuickReorder(
      BookingModel lastBooking, ServicesProvider servicesProvider) {
    return GestureDetector(
      onTap: () {
        final service = servicesProvider.getServiceById(lastBooking.serviceId);
        if (service != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(service: service),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surfaceContainerHigh,
              ),
              child: lastBooking.serviceImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        lastBooking.serviceImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: Icon(Icons.history_rounded, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.history_rounded, color: AppColors.onSurfaceVariant),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book again',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastBooking.serviceName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Reorder',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // SERVICE CARD
  // ════════════════════════════════════════════════════════
  Widget _buildServiceCard(ServiceModel service, CartProvider cart) {
    final isInCart = cart.isInCart(service.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(service: service),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isInCart
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: service.image != null
                        ? Image.asset(
                            service.image!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _buildImageFallback(service),
                          )
                        : _buildImageFallback(service),
                  ),
                  // Tags
                  if (service.tags.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          service.tags.first,
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Availability
                  if (!service.isAvailableNow)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.9),
                        child: Text(
                          'Next: ${service.nextAvailableSlot ?? 'Soon'}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info Area
            Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.displayTitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, color: AppColors.onSurfaceVariant, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          service.duration,
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star_rounded, color: AppColors.tertiary, size: 10),
                        const SizedBox(width: 2),
                        Text(
                          '${service.rating}',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          service.basePrice == 0 ? 'Free' : '₹${service.basePrice.toInt()}',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Add Button
                        GestureDetector(
                          onTap: () {
                            if (isInCart) {
                              cart.removeService(service.id);
                            } else if (service.options.isNotEmpty) {
                              cart.addService(service, service.options.first);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isInCart ? AppColors.primary : AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isInCart ? 'Added' : 'Add',
                              style: TextStyle(
                                color: isInCart ? AppColors.onPrimary : AppColors.onSurface,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
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
      ),
    );
  }

  Widget _buildImageFallback(ServiceModel service) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          size: 28,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // CART BAR
  // ════════════════════════════════════════════════════════
  Widget _buildCartBar(CartProvider cart) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: MediaQuery.of(context).padding.bottom + 100, // Above bottom nav
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${cart.itemCount}',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${cart.total.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cart.isAsap ? 'ASAP • ~10 min' : 'Scheduled • ${cart.estimatedTime}',
                      style: TextStyle(
                        color: AppColors.onPrimary.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    'View cart',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.onPrimary, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // ADDRESS PICKER BOTTOM SHEET
  // ════════════════════════════════════════════════════════
  void _showAddressPicker(BuildContext context) {
    final location = context.read<LocationProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Select Address',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            // Detect location button
            GestureDetector(
              onTap: () {
                location.detectLocation();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use Current Location',
                            style: TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Using GPS',
                            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Saved Addresses',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Saved addresses
            ...location.savedAddresses.map((addr) {
              final isSelected = location.currentAddress?.id == addr.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    location.selectAddress(addr);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          addr.label == 'Home'
                              ? Icons.home_outlined
                              : addr.label == 'Office'
                                  ? Icons.work_outline
                                  : Icons.location_on_outlined,
                          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                addr.label,
                                style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                addr.shortDisplay,
                                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                      ],
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
