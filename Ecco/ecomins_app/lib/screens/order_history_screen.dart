import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../providers/booking_provider.dart';
import '../data/models/booking_model.dart';
import 'booking_details_screen.dart';
import 'impact_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final active = bookingProvider.activeBookings;
    final past = bookingProvider.completedBookings;
    final allBookings = bookingProvider.bookings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Bookings',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${allBookings.length} total bookings',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildImpactRow(allBookings),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.onPrimary,
                  unselectedLabelColor:
                      AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: [
                    Tab(text: 'Active (${active.length})'),
                    Tab(text: 'Past (${past.length})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingList(active, isActive: true),
                  _buildBookingList(past, isActive: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactRow(List<BookingModel> bookings) {
    final totalCarbon = bookings.fold<double>(
        0.0, (sum, b) => sum + b.carbonSaved);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildImpactTile(context, Icons.eco_outlined, '${totalCarbon.toStringAsFixed(1)}kg', 'CO₂ Saved', 'Represents the total volume of greenhouse gases prevented from entering the atmosphere through zero-emission Eco-Partner services.'),
          const SizedBox(width: 12),
          _buildImpactTile(context, Icons.stars_outlined, '${bookings.length * 150}', 'Points Earned', 'Highlights your total accumulated OzoMin Eco-Rewards which can be converted to wallet balance or donated to tree planting charities.'),
          const SizedBox(width: 12),
          _buildImpactTile(context, Icons.park_outlined, '${(totalCarbon / 4.5).ceil()}', 'Trees Equiv.', 'Translates your carbon savings into the equivalent amount of carbon sequestered by adult trees over an entire year.'),
        ],
      ),
    );
  }

  Widget _buildImpactTile(BuildContext context, IconData icon, String value, String label, String desc) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImpactDetailsScreen(
                title: label,
                value: value,
                emoji: 'icon', // Hack for compatibility, ideally update ImpactDetailsScreen too
                description: desc,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: TextStyle(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings,
      {required bool isActive}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.calendar_today_outlined : Icons.history_outlined,
              size: 48,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active bookings' : 'No past bookings',
              style: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (ctx, idx) => _buildBookingCard(context, bookings[idx], isActive),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking, bool isActive) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailsScreen(booking: booking, isActive: isActive),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: booking.serviceImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(booking.serviceImage!, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Icon(Icons.eco_outlined, color: AppColors.onSurfaceVariant),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.serviceName,
                        style: const TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(booking.scheduledAt)}  •  ${DateFormat('hh:mm a').format(booking.scheduledAt)}',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : 'DONE',
                  style: TextStyle(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded,
                      color: AppColors.onSurfaceVariant, size: 16),
                  const SizedBox(width: 4),
                  Text(booking.workerName ?? 'Assigning...',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.eco_outlined, color: AppColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.carbonSaved.toStringAsFixed(1)}kg  ',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${booking.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
