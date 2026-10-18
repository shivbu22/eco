import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      image: 'assets/images/onboarding_eco_city.png',
      title: 'Clean living,\nmade simple',
      subtitle: 'Book verified eco-friendly services for your home in just a few taps.',
      accent: AppColors.primary,
      onAccent: AppColors.onPrimary,
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding_plant_tree.png',
      title: 'Track your\neco impact',
      subtitle: 'See how your choices reduce emissions and support sustainable communities.',
      accent: AppColors.tertiary,
      onAccent: AppColors.onPrimary, // Or AppColors.onTertiary if defined
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 24),
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (ctx, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Editorial image area
                        Container(
                          height: MediaQuery.of(context).size.height * 0.45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.surfaceContainerLow,
                            border: Border.all(
                              color: AppColors.outlineVariant.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              page.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: page.accent.withValues(alpha: 0.05),
                                child: Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 64,
                                    color: page.accent.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Title
                        Text(
                          page.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
                        Text(
                          page.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom section: dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Row(
                children: [
                  // Dots
                  Row(
                    children: List.generate(_pages.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? _pages[_currentPage].accent
                              : AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  // Next / Get Started button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage == _pages.length - 1) {
                        _navigateToLogin();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: _pages[_currentPage].accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Get started'
                                : 'Next',
                            style: TextStyle(
                              color: _pages[_currentPage].onAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: _pages[_currentPage].onAccent,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
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

class _OnboardingPage {
  final String image;
  final String title;
  final String subtitle;
  final Color accent;
  final Color onAccent;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onAccent,
  });
}
