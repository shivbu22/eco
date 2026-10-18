import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/auth_guard.dart';
import 'quick_home_screen.dart';
import 'sustainability_impact_screen.dart';
import 'order_history_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const QuickHomeScreen(),                        // HOME - public
    const SustainabilityImpactScreen(),              // IMPACT - public
    const AuthGuard(                                 // BOOKINGS - protected
      featureName: 'My Bookings',
      child: OrderHistoryScreen(),
    ),
    const AuthGuard(                                 // WALLET - protected
      featureName: 'Wallet',
      child: WalletScreen(),
    ),
    const ProfileScreen(),                           // PROFILE - public
  ];

  final List<_NavItem> _navItems = [
    _NavItem(Icons.home_rounded, Icons.home_outlined, 'HOME'),
    _NavItem(Icons.eco_rounded, Icons.eco_outlined, 'IMPACT'),
    _NavItem(Icons.calendar_today_rounded, Icons.calendar_today_outlined, 'BOOKINGS'),
    _NavItem(Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, 'WALLET'),
    _NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border(
              top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.2))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _navItems.length,
            (i) => _buildNavItem(_navItems[i], i),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  const _NavItem(this.activeIcon, this.icon, this.label);
}
