import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/database_service.dart';

class SmartSchedulingScreen extends StatefulWidget {
  const SmartSchedulingScreen({super.key});

  @override
  State<SmartSchedulingScreen> createState() => _SmartSchedulingScreenState();
}

class _SmartSchedulingScreenState extends State<SmartSchedulingScreen> {
  final DatabaseService _db = DatabaseService();
  late Map<String, dynamic> _data;
  int _selectedDay = 13;

  @override
  void initState() {
    super.initState();
    _data = _db.getScheduledServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () {}),
        title: Text('OZOMIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
            letterSpacing: 2, color: AppColors.primary, fontStyle: FontStyle.italic)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
            ),
            child: const Icon(Icons.person, size: 18, color: Colors.white70),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('SUBSCRIPTION MANAGEMENT',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 1.5, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            const Text('Your Services',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 20),

            // ── Active Service Cards ──
            ...(_data['activeServices'] as List).map((s) => _buildServiceCard(s)),
            const SizedBox(height: 24),

            // ── Calendar ──
            _buildCalendar(),
            const SizedBox(height: 12),

            // ── Next Service ──
            _buildNextServiceCard(),
            const SizedBox(height: 28),

            // ── Explore Plans ──
            Row(
              children: [
                const Text('Explore Plans',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                const Spacer(),
                Row(
                  children: [
                    Text('View All', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                    Icon(Icons.arrow_forward, size: 16, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (_data['plans'] as List).length,
                itemBuilder: (context, i) {
                  final plan = (_data['plans'] as List)[i];
                  return _buildPlanCard(plan);
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── Impact Score ──
            _buildImpactScoreCard(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(service['icon'], style: const TextStyle(fontSize: 22))),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(service['status'],
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(service['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoLabel('FREQUENCY', service['frequency']),
              const SizedBox(width: 24),
              _infoLabel('NEXT DATE', service['nextDate']),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('AUTO-PAY STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  letterSpacing: 0.8, color: AppColors.onSurfaceVariant)),
              const SizedBox(width: 8),
              Icon(Icons.check_circle, color: AppColors.primary, size: 14),
              const SizedBox(width: 4),
              Text('Enabled', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoLabel(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
            letterSpacing: 0.8, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildCalendar() {
    final scheduledDates = _data['scheduledDates'] as List;
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Service Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              const Spacer(),
              Text('OCTOBER', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),
          // Day headers
          Row(
            children: days.map((d) => Expanded(
              child: Center(child: Text(d, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant))),
            )).toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          ...List.generate(5, (week) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: List.generate(7, (day) {
                  final date = week * 7 + day - 1; // Simplified
                  if (date < 1 || date > 31) return const Expanded(child: SizedBox(height: 36));
                  final isScheduled = scheduledDates.contains(date);
                  final isSelected = date == _selectedDay;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDay = date),
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$date',
                                style: TextStyle(fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                    color: isSelected ? AppColors.onPrimary
                                        : date < 6 ? AppColors.onSurfaceVariant.withValues(alpha: 0.3)
                                        : Colors.white)),
                            if (isScheduled && !isSelected)
                              Container(
                                width: 4, height: 4,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNextServiceCard() {
    final next = _data['nextService'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tertiary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Next Service: ${next['title']}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(next['time'],
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceContainer,
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.background.withValues(alpha: 0.9)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: plan['tag'] == 'Most Popular' ? AppColors.primary : AppColors.primary.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(plan['tag'],
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary)),
                ),
                const SizedBox(height: 8),
                Text(plan['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(plan['desc'],
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('IMPACT SCORE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  letterSpacing: 1, color: AppColors.primary)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_data['impactScore']}',
                      style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text('KG CO2 SAVED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white60)),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Colors.black, size: 28),
          ),
        ],
      ),
    );
  }
}
