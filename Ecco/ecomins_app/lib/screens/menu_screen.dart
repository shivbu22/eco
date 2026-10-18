import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'profile_screen.dart';
import 'payment_methods_screen.dart';
import 'eco_store_marketplace_screen.dart';
import 'community_forum_screen.dart';
import 'live_support_chat_screen.dart';
import 'saved_addresses_screen.dart';
import 'eco_rewards_marketplace_screen.dart';
import 'notifications_screen.dart';
import 'referral_program_screen.dart';
import 'subscription_tiers_screen.dart';
import 'ancient_wisdom_screen.dart';
import 'about_us_screen.dart';
import 'settings_privacy_screen.dart';
import 'terms_conditions_screen.dart';
import 'privacy_policy_screen.dart';
import 'edit_profile_screen.dart';
import 'rate_service_screen.dart';
import 'achievements_gallery_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Explore OzoMin',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                      },
                      icon: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 18,
                        child: Icon(Icons.person, color: AppColors.background, size: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Profile Card Shortcut
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: _buildBannerCard(
                  context,
                  title: 'Namaste, Eco-Warrior!',
                  subtitle: 'Manage your profile and settings >',
                  icon: Icons.eco,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                ),
              ),
            ),

            _buildSectionHeader('Prakriti (Eco-Impact)'),
            _buildGridSection(context, [
              _MenuOption('Achievements', Icons.military_tech, const AchievementsGalleryScreen()),
              _MenuOption('Ancient Wisdom', Icons.auto_stories, const AncientWisdomScreen()),
              _MenuOption('Eco Store', Icons.shopping_bag, const EcoStoreMarketplaceScreen()),
              _MenuOption('Community', Icons.groups, const CommunityForumScreen()),
            ]),

            _buildSectionHeader('Wealth & Offers (Karma)'),
            _buildGridSection(context, [
              _MenuOption('Ozo Rewards', Icons.card_giftcard, const EcoRewardsMarketplaceScreen()),
              _MenuOption('Refer & Earn', Icons.currency_rupee, const ReferralProgramScreen()),
              _MenuOption('Eco Plans', Icons.workspace_premium, const SubscriptionTiersScreen()),
              _MenuOption('Vouchers', Icons.local_offer, const Scaffold()), // Stub
            ]),

            _buildSectionHeader('Settings & Utility'),
            _buildGridSection(context, [
              _MenuOption('Payment Methods', Icons.account_balance_wallet, const PaymentMethodsScreen()),
              _MenuOption('My Addresses', Icons.home_work, const SavedAddressesScreen()),
              _MenuOption('Notifications', Icons.notifications, const NotificationsScreen()),
              _MenuOption('Edit Profile', Icons.edit_document, const EditProfileScreen()),
              _MenuOption('Language (भाषा)', Icons.language, const Scaffold()), // Stub Language Selector
              _MenuOption('Partner Ratings', Icons.star_rate, const RateServiceScreen()),
              _MenuOption('Live Chat', Icons.support_agent, const LiveSupportChatScreen()),
              _MenuOption('Privacy & Safety', Icons.security, const SettingsPrivacyScreen()),
            ]),

            _buildSectionHeader('About'),
            _buildGridSection(context, [
              _MenuOption('About OzoMin', Icons.info_outline, const AboutUsScreen()),
              _MenuOption('Terms & Cond.', Icons.gavel, const TermsConditionsScreen()),
              _MenuOption('Privacy Policy', Icons.policy, const PrivacyPolicyScreen()),
              _MenuOption('Log Out', Icons.logout, null, isDestructive: true),
            ]),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: Colors.green[800], size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
      ),
    );
  }

  Widget _buildGridSection(BuildContext context, List<_MenuOption> options) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final opt = options[index];
            return GestureDetector(
              onTap: opt.screen != null ? () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => opt.screen!));
              } : null,
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: opt.isDestructive ? Colors.red.withValues(alpha: 0.1) : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: opt.isDestructive ? Colors.red.withValues(alpha: 0.2) : AppColors.outlineVariant.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Icon(
                      opt.icon,
                      color: opt.isDestructive ? Colors.redAccent : AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    opt.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: opt.isDestructive ? Colors.redAccent : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: options.length,
        ),
      ),
    );
  }
}

class _MenuOption {
  final String label;
  final IconData icon;
  final Widget? screen;
  final bool isDestructive;

  _MenuOption(this.label, this.icon, this.screen, {this.isDestructive = false});
}
