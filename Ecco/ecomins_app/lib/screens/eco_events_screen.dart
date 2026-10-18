import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/database_service.dart';

class EcoEventsScreen extends StatefulWidget {
  const EcoEventsScreen({super.key});

  @override
  State<EcoEventsScreen> createState() => _EcoEventsScreenState();
}

class _EcoEventsScreenState extends State<EcoEventsScreen> {
  final DatabaseService _db = DatabaseService();
  late List<Map<String, dynamic>> _events;
  late Map<String, int> _categories;
  String _activeFilter = 'All';
  final Set<String> _joinedEvents = {};

  @override
  void initState() {
    super.initState();
    _events = _db.getEcoEvents();
    _categories = _db.getEventCategories();
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_activeFilter == 'All') return _events;
    return _events.where((e) => e['category'] == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('OZOMIN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                letterSpacing: 2, color: AppColors.primary, fontStyle: FontStyle.italic)),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
              Positioned(
                right: 10, top: 10,
                child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tertiary),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('COMMUNITY & IMPACT EVENTS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 1.5, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            const Text('Eco Events',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 20),

            // ── Filter Chips ──
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('All', null),
                  ..._categories.entries.map((e) => _filterChip(e.key, e.value)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Featured Event Card ──
            if (_filteredEvents.isNotEmpty)
              _buildFeaturedCard(_filteredEvents.first),
            const SizedBox(height: 24),

            // ── Event List ──
            if (_filteredEvents.length > 1)
              ..._filteredEvents.skip(1).map((e) => _buildEventCard(e)),
            const SizedBox(height: 28),

            // ── Stats Bar ──
            _buildStatsRow(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int? count) {
    final isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.onPrimary : AppColors.onSurface)),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.onPrimary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$count',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: isActive ? AppColors.onPrimary : AppColors.primary)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> event) {
    final isJoined = _joinedEvents.contains(event['id']);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.surfaceContainer,
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image placeholder
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.surfaceContainer,
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(child: Icon(Icons.event_rounded, size: 60, color: AppColors.primary.withValues(alpha: 0.3))),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('FEATURED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                        color: AppColors.onPrimary, letterSpacing: 0.8)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(event['category'],
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
                const SizedBox(height: 10),
                Text(event['title'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 6),
                Text(event['desc'],
                    style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.4),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(event['date'],
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    const Spacer(),
                    Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(event['location'],
                        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('+${event['points']} pts',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => setState(() {
                          isJoined ? _joinedEvents.remove(event['id']) : _joinedEvents.add(event['id']);
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isJoined ? AppColors.surfaceContainerHigh : AppColors.primary,
                          foregroundColor: isJoined ? AppColors.primary : AppColors.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Text(isJoined ? 'JOINED' : 'JOIN EVENT',
                            style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
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

  Widget _buildEventCard(Map<String, dynamic> event) {
    final isJoined = _joinedEvents.contains(event['id']);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(event['date'].toString().substring(0, 6),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: AppColors.primary, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['title'],
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(event['desc'],
                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('+${event['points']} pts',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() {
                        isJoined ? _joinedEvents.remove(event['id']) : _joinedEvents.add(event['id']);
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isJoined ? AppColors.primary.withValues(alpha: 0.12) : AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(isJoined ? 'JOINED' : 'JOIN',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                color: isJoined ? AppColors.primary : AppColors.onPrimary)),
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

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Events\nJoined', '${_joinedEvents.length}'),
          Container(width: 1, height: 40, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          _statItem('Points\nEarned', '0'),
          Container(width: 1, height: 40, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          _statItem('Community\nRank', '#3'),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.3)),
      ],
    );
  }
}
