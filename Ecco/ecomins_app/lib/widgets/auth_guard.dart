import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../theme/app_colors.dart';

/// A widget that protects its child from unauthorized access.
/// If the user is not authenticated, it redirects to the LoginScreen.
/// If [guestAllowed] is true, guest users can access the child.
class AuthGuard extends StatelessWidget {
  final Widget child;
  final bool guestAllowed;
  final String? featureName;

  const AuthGuard({
    super.key,
    required this.child,
    this.guestAllowed = false,
    this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Still loading auth state
        if (auth.status == AuthStatus.authenticating) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verifying session...',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Not authenticated at all - redirect to login
        if (!auth.isAuthenticated) {
          // Use post-frame callback to avoid build-phase navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          });
          return const SizedBox.shrink();
        }

        // Guest user trying to access a protected feature
        if (auth.isGuest && !guestAllowed) {
          return _buildGuestRestrictionScreen(context, auth);
        }

        return child;
      },
    );
  }

  Widget _buildGuestRestrictionScreen(BuildContext context, AuthProvider auth) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  size: 36,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                featureName != null
                    ? '$featureName requires sign-in'
                    : 'Sign in required',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Create a free account to unlock all features and track your eco-impact.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign In / Sign Up',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Go Back',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
