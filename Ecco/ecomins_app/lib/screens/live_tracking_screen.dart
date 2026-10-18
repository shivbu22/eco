import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/booking_provider.dart';
import '../data/models/booking_model.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final booking = bookingProvider.activeBooking;
        
        // Fallback coords (Bengaluru)
        final destLat = booking?.address.latitude ?? 12.9348;
        final destLng = booking?.address.longitude ?? 77.6102;
        final workerLat = booking?.workerLatitude ?? (destLat + 0.005);
        final workerLng = booking?.workerLongitude ?? (destLng + 0.005);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: 0.8), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              booking?.serviceName ?? 'Live Tracking',
              style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              if (booking != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        'ID: ${booking.id.split('_').first.toUpperCase()}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                )
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Column(
            children: [
              // Map Area
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          (destLat + workerLat) / 2,
                          (destLng + workerLng) / 2,
                        ),
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          tileBuilder: (context, tileWidget, tile) {
                            return ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                -0.21, -0.72, -0.07, 0, 255,
                                -0.21, -0.72, -0.07, 0, 255,
                                -0.21, -0.72, -0.07, 0, 255,
                                0, 0, 0, 1, 0,
                              ]),
                              child: tileWidget,
                            );
                          },
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [LatLng(workerLat, workerLng), LatLng(destLat, destLng)],
                              color: AppColors.primary.withValues(alpha: 0.5),
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            // Destination Marker
                            Marker(
                              point: LatLng(destLat, destLng),
                              width: 80,
                              height: 80,
                              child: Column(
                                children: [
                                  const Icon(Icons.location_on, color: AppColors.primary, size: 40),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('You', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                            ),
                            // Worker Marker
                            Marker(
                              point: LatLng(workerLat, workerLng),
                              width: 60,
                              height: 60,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)],
                                    ),
                                  ),
                                  const Positioned(
                                    top: 0,
                                    child: Icon(Icons.directions_run, color: AppColors.primary, size: 18),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // ETA Badge overlay
                    if (booking != null && booking.status == BookingStatus.enRoute)
                      Positioned(
                        top: 100,
                        right: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt, color: AppColors.onPrimary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Arriving in ${booking.etaMinutes} min',
                                style: const TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),

              // Info Overlay Card
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 12))],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    (booking?.workerName ?? 'R')[0],
                                    style: const TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.bold, fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking?.workerName ?? 'Assigning...',
                                      style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${booking?.workerRating ?? 0.0}',
                                          style: const TextStyle(color: AppColors.secondary, fontSize: 14),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('STATUS', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                Row(
                                  children: [
                                    Icon(
                                      booking?.status == BookingStatus.inProgress
                                          ? Icons.build_circle_outlined
                                          : Icons.directions_walk,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      booking?.status == BookingStatus.inProgress
                                          ? 'Working'
                                          : 'On the way',
                                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.call, size: 20),
                                label: const Text('Call'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.chat_bubble, size: 20),
                                label: const Text('Chat'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // Timeline
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _buildTimelineTile(Icons.check, 'Booking Confirmed', '2:30 PM', isCompleted: true),
                      _buildTimelineTile(Icons.check, 'Worker Assigned', '2:31 PM', isCompleted: true),
                      _buildTimelineTile(
                        Icons.directions_run,
                        'Worker En Route',
                        booking?.status == BookingStatus.enRoute ? '${booking?.etaMinutes} min away · Tracking live' : 'Completed',
                        isActive: booking?.status == BookingStatus.enRoute,
                        isCompleted: booking?.status == BookingStatus.inProgress || booking?.status == BookingStatus.completed,
                      ),
                      _buildTimelineTile(
                        booking?.status == BookingStatus.inProgress ? Icons.check : null,
                        'Worker Arrived',
                        booking?.status == BookingStatus.inProgress ? 'Service in progress' : '~2:36 PM',
                        isActive: booking?.status == BookingStatus.inProgress,
                        isDisabled: booking?.status == BookingStatus.enRoute,
                      ),
                      _buildTimelineTile(null, 'Service Completed', '', isLast: true, isDisabled: booking?.status != BookingStatus.completed),
                      
                      const SizedBox(height: 24),
                      
                      // Live Update Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.near_me, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking?.status == BookingStatus.inProgress
                                        ? 'Service is in progress · Worker is at your location'
                                        : 'Worker is ${((workerLat - destLat).abs() * 111).toStringAsFixed(1)} km away · Moving towards you',
                                    style: const TextStyle(color: AppColors.onSurface, fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  const Text('Last updated: Just now', style: TextStyle(color: AppColors.secondary, fontSize: 10)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      if (booking != null && booking.status == BookingStatus.enRoute)
                        TextButton(
                          onPressed: () {
                            context.read<BookingProvider>().cancelBooking(booking.id);
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel Booking', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                        ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineTile(IconData? icon, String title, String time, {bool isCompleted = false, bool isActive = false, bool isLast = false, bool isDisabled = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDisabled ? AppColors.surfaceContainerHighest : (isActive ? AppColors.primaryContainer : AppColors.primary),
                shape: BoxShape.circle,
                border: isDisabled ? Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)) : null,
                boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 4)] : null,
              ),
              child: icon != null 
                ? Icon(icon, color: AppColors.onPrimary, size: 14) 
                : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.2),
              )
          ],
        ),
        const SizedBox(width: 16),
        Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isActive ? AppColors.primary : AppColors.onSurface, fontWeight: isActive ? FontWeight.bold : FontWeight.w600, fontSize: 14)),
              if (time.isNotEmpty)
                Text(time, style: const TextStyle(color: AppColors.secondary, fontSize: 11)),
            ],
          ),
        )
      ],
    );
  }
}
