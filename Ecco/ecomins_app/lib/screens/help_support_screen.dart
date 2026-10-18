import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () {},
        ),
        title: const Text(
          'OZOMIN',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            fontStyle: FontStyle.italic,
            letterSpacing: -1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.onSurface),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA0vOmmrWA3Ac0XiICNSrmAajDZhZ5gKSum6GWD53_uo9CHupxq2bdd-mriP0cvWqLDc6Ji2zpjv8L_LL7wvVWwXfvhI9so4LjSQ5zQBc-izRXp-OF2pNRXjGKpXz5n5d-jmaXmZM3Xkq6eVM0jwp64ANWZUflut26D1sKZKQzo0xZhVsxStaVW6VRmsfNw0RjGl7cdq6tm9etISfWiDBDJqHd8X_nROrVQcm47vv_B1otoPR-bczFyhXW4v7xHUd-DavcGAEMagF4'),
              backgroundColor: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            RichText(
              text: const TextSpan(
                style: TextStyle(color: AppColors.onSurface, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.5, height: 1.1),
                children: [
                  TextSpan(text: 'How can we '),
                  TextSpan(text: 'help?', style: TextStyle(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                style: TextStyle(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search for answers, guides, or tickets...',
                  hintStyle: TextStyle(color: AppColors.outline),
                  prefixIcon: Icon(Icons.search, color: AppColors.outline),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Bento Grid Categories
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
              children: [
                _buildCategoryItem(Icons.calendar_month, 'Booking Issues', 'Reschedule or cancel'),
                _buildCategoryItem(Icons.account_balance_wallet, 'Payments', 'Eco-credits & billing'),
                _buildCategoryItem(Icons.eco, 'Eco-Impact', 'Carbon tracking help'),
                _buildCategoryItem(Icons.build, 'Technical', 'App & sensor issues'),
              ],
            ),
            const SizedBox(height: 48),

            // Tickets Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.confirmation_num, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Recent tickets', style: TextStyle(color: AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View history', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 12),
            _buildTicketCard(
              title: 'Delay in garbage pickup',
              id: '#ECM-8821',
              time: 'Created 2 days ago',
              status: 'Resolved',
              isActive: true,
            ),
            const SizedBox(height: 12),
            _buildTicketCard(
              title: 'Subscription upgrade issue',
              id: '#ECM-8744',
              time: 'Created 1 week ago',
              status: 'Closed',
              isActive: false,
            ),
            const SizedBox(height: 48),

            // Contact Options
            const Text('Contact Us', style: TextStyle(color: AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            _buildContactItem(Icons.mail, 'Email Support', 'Response within 2 hours'),
            const SizedBox(height: 8),
            _buildContactItem(Icons.call, 'Call Center', '9 AM - 6 PM (Mon-Fri)'),
            const SizedBox(height: 8),
            _buildContactItem(Icons.chat, 'WhatsApp', 'Instant connectivity'),
            
            const SizedBox(height: 32),
            
            // Priority Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(Icons.verified_user, color: AppColors.primary.withValues(alpha: 0.2), size: 64),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Emerald Priority', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(
                        'Emerald members get skip-the-line technical support 24/7.',
                        style: TextStyle(color: AppColors.onSurface.withValues(alpha: 0.9), height: 1.6),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Upgrade Now', style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width - 48,
        height: 64,
        margin: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: AppColors.primary,
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          label: Row(
            children: const [
               Icon(Icons.smart_toy, color: AppColors.onPrimary),
               SizedBox(width: 12),
               Text('Chat with Eco-Bot', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCategoryItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 13, height: 1.1)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard({required String title, required String id, required String time, required String status, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.05)),
      ),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.6,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.outlineVariant,
                shape: BoxShape.circle,
                boxShadow: isActive ? [const BoxShadow(color: AppColors.primary, blurRadius: 8)] : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Ticket $id • $time', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'STATUS: $status',
                style: TextStyle(color: isActive ? AppColors.primary : AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
