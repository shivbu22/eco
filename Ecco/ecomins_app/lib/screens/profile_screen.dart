import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import 'referral_program_screen.dart';
import 'my_bookings_screen.dart';
import 'saved_addresses_screen.dart';
import 'manage_account_screen.dart';
import 'help_support_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_privacy_screen.dart';
import 'order_history_screen.dart';
import 'about_us_screen.dart';
import 'eco_tips_screen.dart';
import 'promotions_screen.dart';
import 'wallet_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildAvatarSection(),
              const SizedBox(height: 32),
              _buildFeatureGrid(context),
              const SizedBox(height: 24),
              _buildReferralBanner(context),
              const SizedBox(height: 32),
              _buildAccountSection(),
              const SizedBox(height: 48),
              Text(
                'App version 4.0.0',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPrivacyScreen()),
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Icon(
              Icons.settings_outlined,
              color: AppColors.onSurface,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        final name = user?.name ?? 'Guest User';
        final subtitle = user?.email.isNotEmpty == true
            ? user!.email
            : (user?.phone.isNotEmpty == true ? user!.phone : 'Eco Explorer');

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHigh,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  // Online indicator
                  if (auth.isAuthenticated && !auth.isGuest)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 4),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit_outlined,
                    color: AppColors.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              if (user != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_outlined, color: AppColors.primary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        user.tier,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (user.ecoPoints > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${user.ecoPoints} pts',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: [
        _FeatureCard(
          icon: Icons.calendar_today_outlined,
          title: 'My Bookings',
          subtitle: 'View all bookings',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
          ),
        ),
        _FeatureCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'My Wallet',
          subtitle: '₹0',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WalletScreen()),
          ),
        ),
        _FeatureCard(
          icon: Icons.local_offer_outlined,
          title: 'All Offers',
          subtitle: '5 active offers',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PromotionsScreen()),
          ),
        ),
        _FeatureCard(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          subtitle: 'Get quick help',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReferralProgramScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earn ₹150',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Refer your friends and earn now',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'MANAGE ACCOUNT',
            style: TextStyle(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _buildAccountTile(
                icon: Icons.location_on_outlined,
                title: 'Saved Addresses',
                showDivider: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedAddressesScreen()),
                ),
              ),
              _buildAccountTile(
                icon: Icons.history_rounded,
                title: 'Order History',
                showDivider: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                ),
              ),
              _buildAccountTile(
                icon: Icons.manage_accounts_outlined,
                title: 'Manage Account',
                showDivider: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageAccountScreen()),
                ),
              ),
              _buildAccountTile(
                icon: Icons.eco_outlined,
                title: 'Eco Tips',
                showDivider: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EcoTipsScreen()),
                ),
              ),
              _buildAccountTile(
                icon: Icons.info_outline_rounded,
                title: 'About OzoMin',
                showDivider: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                ),
              ),
              _buildAccountTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                titleColor: AppColors.error,
                showDivider: false,
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTile({
    required IconData icon,
    required String title,
    required bool showDivider,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: titleColor ?? AppColors.onSurfaceVariant, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: titleColor ?? AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                  size: 20,
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              indent: 58,
              endIndent: 20,
              color: AppColors.outlineVariant.withValues(alpha: 0.15),
            ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.onSurface, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
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
    );
  }
}
