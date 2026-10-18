import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SeasonalChallengesScreen extends StatefulWidget {
  const SeasonalChallengesScreen({super.key});

  @override
  State<SeasonalChallengesScreen> createState() => _SeasonalChallengesScreenState();
}

class _SeasonalChallengesScreenState extends State<SeasonalChallengesScreen> with SingleTickerProviderStateMixin {
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

  final List<Map<String, dynamic>> _activeChallenges = [
    {
      'title': 'Earth Month Challenge',
      'description': 'Complete 5 eco services this April and earn exclusive Earth Day badge + 500 green points.',
      'image': 'assets/images/garden_care.png',
      'progress': 0.6,
      'progressText': '3/5 services',
      'reward': '500 pts + Badge',
      'daysLeft': 23,
      'color': AppColors.primary,
      'participants': 1240,
    },
    {
      'title': 'Zero Waste Week',
      'description': 'Book recycling pickup 3 times this week and reduce your waste footprint to zero.',
      'image': 'assets/images/recycling_pickup.png',
      'progress': 0.33,
      'progressText': '1/3 pickups',
      'reward': '200 pts',
      'daysLeft': 4,
      'color': const Color(0xFF64B5F6),
      'participants': 856,
    },
    {
      'title': 'Solar Power Sprint',
      'description': 'Get your solar panels cleaned and monitored for maximum efficiency this summer.',
      'image': 'assets/images/solar_cleaning.png',
      'progress': 0.0,
      'progressText': '0/1 cleaning',
      'reward': '150 pts',
      'daysLeft': 30,
      'color': const Color(0xFFFFD54F),
      'participants': 432,
    },
  ];

  final List<Map<String, dynamic>> _completedChallenges = [
    {
      'title': 'Spring Clean Streak',
      'description': 'Booked 3 eco deep cleaning sessions in March.',
      'image': 'assets/images/eco_cleaning.png',
      'reward': '300 pts + Badge',
      'color': const Color(0xFF66BB6A),
      'completedDate': 'Mar 28, 2026',
    },
    {
      'title': 'Water Saver Hero',
      'description': 'Completed water tank cleaning and installed low-flow fixtures.',
      'image': 'assets/images/water_tank.png',
      'reward': '250 pts',
      'color': const Color(0xFF4FC3F7),
      'completedDate': 'Mar 10, 2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header
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
                    'Challenges',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFD54F).withValues(alpha: 0.2),
                          const Color(0xFFFFB74D).withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD54F), size: 16),
                        SizedBox(width: 4),
                        Text(
                          '1,050 pts',
                          style: TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  dividerHeight: 0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Active tab
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _activeChallenges.length,
                    itemBuilder: (ctx, i) => _ActiveChallengeCard(challenge: _activeChallenges[i]),
                  ),
                  // Completed tab
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _completedChallenges.length,
                    itemBuilder: (ctx, i) => _CompletedChallengeCard(challenge: _completedChallenges[i]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;

  const _ActiveChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final Color color = challenge['color'];
    final double progress = challenge['progress'];

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
          // Image header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                Image.asset(
                  challenge['image'],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 160,
                    color: AppColors.surfaceContainerLow,
                    child: Icon(Icons.emoji_events, size: 50, color: color.withValues(alpha: 0.3)),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Days left badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_rounded, color: color, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge['daysLeft']}d left',
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
                // Participants
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Row(
                    children: [
                      // Stacked avatars
                      SizedBox(
                        width: 60,
                        height: 24,
                        child: Stack(
                          children: List.generate(3, (i) {
                            return Positioned(
                              left: i * 18.0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.5 + i * 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.surfaceContainer, width: 2),
                                ),
                                child: const Icon(Icons.person, color: Colors.white, size: 12),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${challenge['participants']} joined',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  challenge['description'],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                // Progress
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                challenge['progressText'],
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: color.withValues(alpha: 0.12),
                              valueColor: AlwaysStoppedAnimation(color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars_rounded, color: color, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            challenge['reward'],
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
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

class _CompletedChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;

  const _CompletedChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final Color color = challenge['color'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            child: Image.asset(
              challenge['image'],
              width: 100,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 100,
                height: 110,
                color: AppColors.surfaceContainerLow,
                child: Icon(Icons.check_circle, size: 30, color: color),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(Icons.check_circle_rounded, color: color, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge['description'],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          challenge['reward'],
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        challenge['completedDate'],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.25),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
