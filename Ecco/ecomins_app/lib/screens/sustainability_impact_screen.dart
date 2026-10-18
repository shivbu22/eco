import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/database_service.dart';

class SustainabilityImpactScreen extends StatefulWidget {
  const SustainabilityImpactScreen({super.key});

  @override
  State<SustainabilityImpactScreen> createState() => _SustainabilityImpactScreenState();
}

class _SustainabilityImpactScreenState extends State<SustainabilityImpactScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  late Map<String, dynamic> _stats;
  int _chartTab = 0; // 0=Weekly, 1=Monthly

  @override
  void initState() {
    super.initState();
    _stats = _db.getImpactStats();
  }

  @override
  Widget build(BuildContext context) {
    final xpProgress = (_stats['currentXP'] as int) / (_stats['requiredXP'] as int);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // ── Milestone Header ──
              Text('CURRENT MILESTONE',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      letterSpacing: 1.5, color: AppColors.primary)),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(children: [
                  TextSpan(text: '${_stats['milestone']}\n',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900,
                          color: Colors.white, height: 1.1)),
                  TextSpan(text: 'Level ${_stats['level']}',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900,
                          color: AppColors.primary, fontStyle: FontStyle.italic, height: 1.1)),
                ]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Next Level: ', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  Text('${_stats['nextLevel']}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  Text('${_stats['currentXP']} / ${_stats['requiredXP']} XP',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 8),
              // XP Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: xpProgress,
                  minHeight: 10,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  children: [
                    const TextSpan(text: 'You are in the top '),
                    TextSpan(text: '${_stats['topPercent']}%',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    const TextSpan(text: ' of Ozomin users this month.\nKeep using eco-friendly services to reach the next tier.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── CO2 Card ──
              _buildStatCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.check_circle, color: AppColors.primary, size: 28),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_stats['co2Change'],
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${_stats['co2Prevented']}',
                            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text('kg', style: TextStyle(fontSize: 18, color: Colors.white70)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Total CO2 Emissions Prevented',
                        style: TextStyle(fontSize: 12, color: Colors.white60)),
                    const SizedBox(height: 12),
                    // Mini bar chart
                    Row(
                      children: List.generate(7, (i) {
                        final h = 8.0 + (i * 4.0).clamp(0, 24);
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: h,
                            decoration: BoxDecoration(
                              color: i == 6 ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Trees + Waste Row ──
              Row(
                children: [
                  Expanded(child: _buildMiniStatCard(
                    icon: Icons.forest_rounded,
                    value: '${_stats['treesPlanted']}',
                    label: 'Trees Planted via\nBookings',
                    showAvatars: true,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMiniStatCard(
                    icon: Icons.recycling_rounded,
                    value: '${_stats['wasteRedirected']}',
                    valueSuffix: 'L',
                    label: 'Waste Redirected\nfrom Landfill',
                    showProgress: true,
                    progress: _stats['wasteRedirected'] / _stats['wasteGoal'],
                    progressLabel: 'WEEKLY GOAL: ${_stats['wasteGoal']}L',
                  )),
                ],
              ),
              const SizedBox(height: 28),

              // ── Activity Analytics ──
              const Text('Activity Analytics',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _chartTabButton('Weekly', 0),
                  const SizedBox(width: 16),
                  _chartTabButton('Monthly', 1),
                  const Spacer(),
                  Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 16),
              _buildBarChart(),
              const SizedBox(height: 28),

              // ── Recent Impact Events ──
              Row(
                children: [
                  const Text('RECENT IMPACT EVENTS',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                          letterSpacing: 1, color: Colors.white)),
                  const Spacer(),
                  Text('VIEW ALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 12),
              ...(_stats['recentEvents'] as List).map((e) => _buildEventTile(e)),
              const SizedBox(height: 24),

              // ── Earned Rewards ──
              const Text('Earned Rewards',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 12),
              _buildRewardCard(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }

  Widget _buildMiniStatCard({
    required IconData icon,
    required String value,
    String? valueSuffix,
    required String label,
    bool showAvatars = false,
    bool showProgress = false,
    double progress = 0,
    String progressLabel = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
              if (valueSuffix != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 2),
                  child: Text(valueSuffix, style: const TextStyle(fontSize: 16, color: Colors.white60)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60, height: 1.3)),
          if (showAvatars) ...[
            const SizedBox(height: 12),
            Row(
              children: List.generate(3, (i) => Container(
                margin: const EdgeInsets.only(right: 4),
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1),
                ),
                child: Icon(Icons.person, size: 14, color: AppColors.primary),
              ))..add(Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: Center(child: Text('+11', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary))),
              )),
            ),
          ],
          if (showProgress) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1).toDouble(),
                minHeight: 6,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(progressLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                letterSpacing: 0.8, color: AppColors.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }

  Widget _chartTabButton(String text, int index) {
    final isActive = _chartTab == index;
    return GestureDetector(
      onTap: () => setState(() => _chartTab = index),
      child: Text(text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          decoration: isActive ? TextDecoration.underline : TextDecoration.none,
          decorationColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final List<int> data = List<int>.from(_stats['weeklyActivity']);
    final maxVal = data.reduce((int a, int b) => a > b ? a : b).toDouble();
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayIndex = 3; // Thursday highlighted
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final ratio = (data[i] as num).toDouble() / maxVal;
          final isToday = i == todayIndex;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 110 * ratio,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(days[i],
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: isToday ? AppColors.primary : AppColors.onSurfaceVariant)),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEventTile(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(event['icon'], style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 2),
                Text(event['subtitle'], style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+${event['xp']} XP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
              const SizedBox(height: 2),
              Text(event['time'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard() {
    final reward = (_stats['rewards'] as List).first;
    return Container(
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
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: Icon(Icons.eco, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reward['title'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: AppColors.primary, letterSpacing: 0.8)),
                  Text('Issued by ${reward['issuer']}',
                      style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('You have ${reward['vouchers']} unused vouchers for zero-emission delivery.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurface)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('REDEEM NOW', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 20),
          // Project card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.primary.withValues(alpha: 0.02)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_stats['project']['label'],
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        letterSpacing: 1.2, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(_stats['project']['name'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
