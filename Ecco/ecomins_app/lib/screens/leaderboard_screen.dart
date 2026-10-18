import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/database_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboard = _db.getLeaderboard('mock_user_123');
    final myEntry = leaderboard.firstWhere((e) => e['isMe'] == true,
        orElse: () => leaderboard.last);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.onSurface),
          ),
        ),
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          // My rank card
          _buildMyRankCard(myEntry),
          const SizedBox(height: 16),
          // Tab bar
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
                tabs: const [
                  Tab(text: 'Global'),
                  Tab(text: 'Friends'),
                  Tab(text: 'Local'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Rankings list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRankingList(leaderboard),
                _buildRankingList(leaderboard.take(4).toList()),
                _buildRankingList(leaderboard.skip(2).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankCard(Map<String, dynamic> myEntry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A3A1F), Color(0xFF0D1F10)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 24,
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3), width: 2),
              ),
              child: Center(
                child: Text(
                  '#${myEntry['rank']}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Rank',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(myEntry['co2Saved'] as double).toStringAsFixed(1)} kg CO₂ saved',
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${myEntry['points']}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'points',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingList(List<Map<String, dynamic>> entries) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (ctx, idx) => _buildRankTile(entries[idx]),
    );
  }

  Widget _buildRankTile(Map<String, dynamic> entry) {
    final isMe = entry['isMe'] == true;
    final rank = entry['rank'] as int;

    Color? medalColor;
    if (rank == 1) medalColor = const Color(0xFFFFD700);
    if (rank == 2) medalColor = const Color(0xFFC0C0C0);
    if (rank == 3) medalColor = const Color(0xFFCD7F32);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 36,
            child: medalColor != null
                ? Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: medalColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: medalColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
          ),
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry['avatar'] as String,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name & CO2
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry['name'] as String,
                      style: TextStyle(
                        color: isMe
                            ? AppColors.primary
                            : AppColors.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${(entry['co2Saved'] as double).toStringAsFixed(1)} kg CO₂ saved',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Points
          Text(
            '${entry['points']}',
            style: TextStyle(
              color: isMe ? AppColors.primary : AppColors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
