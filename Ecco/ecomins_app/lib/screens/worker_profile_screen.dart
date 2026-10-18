import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ozomin',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -1.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBbsc7yUfGjo-DB94uJ-sz1mKHwW0bi6B_QT3hJ5rN4pydXU9EskjuYN52q5G5xF58ELe6B9yR3BiOX4TZwE5WIBNGVIVTaKhMS-AcV27eUWp-EBl7iA0U5dBZuFh_-CYh9zzlpAiCXPjEaBeTHy8KBgpfsv1U9NornFNAvZ8kQyvG9ZA6VB9II-MApqZLSd89UDp3hzcH4rsWI5ZPsGGvrqvnSDuru5KXKcQunJW3mxtR4JZR_q6QhLSghpY5Fi9FcGilZG02V8YY'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.8),
          border: const Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.chat_bubble, color: AppColors.onSurface),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Text('BOOK RAJESH NOW'),
                label: const Icon(Icons.bolt, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.0),
                ),
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 120, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAn2omdUjB6a3IvO0aU9B5hHdxUKkqEBoUBRES2hg4wtB6whddGHFAGSuWlf6Kmz__K_i5Z5cIgRV8sbOwwWg2PCdozRGq5XK-xYOtT0cUWsX_ENHAzHSOBVd_3itlqVhqP2UTzdVYpIcpiMoY87-GYl_TSPC6dBsktKMgxpQFomcvSw7XRgztqh4pQygxoCrtXjI4XtRsHZTNT8o3wEWx7966AhgzqVq6wMvi8-i_PaTiB2j9IaVtO0W_THEUhrHGW5YoJ48fGpEE'),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: 5)
                        ]
                      ),
                    ),
                    Positioned(
                      bottom: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('VERIFIED', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1.0)),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.star, color: AppColors.primary, size: 16),
                          SizedBox(width: 4),
                          Text('4.9', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                          SizedBox(width: 8),
                          Text('(124 Reviews)', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Rajesh K.',
                        style: TextStyle(color: AppColors.onSurface, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -2.0, height: 1.0),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SOLAR SOLUTIONS ARCHITECT',
                        style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Stats row
            Row(
              children: [
                Expanded(child: _buildStatCard('EXPERIENCE', '8+ Years')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('IMPACT', '12.4t CO2e', textColor: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 32),

            // Bio
            const Text('PROFESSIONAL BIO', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
            const SizedBox(height: 12),
            Text(
              'Specializing in hyper-efficient residential energy ecosystems. I transition homes from grid-dependence to carbon-negative status using precision solar arrays and smart-battery integration.',
              style: TextStyle(color: AppColors.onSurface.withValues(alpha: 0.9), height: 1.6),
            ),
            const SizedBox(height: 32),

            // Expertise
            const Text('EXPERTISE & SERVICES', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
            const SizedBox(height: 16),
            _buildServiceItem(
              icon: Icons.solar_power,
              title: 'Solar Array Diagnostic',
              subtitle: 'Efficiency mapping',
              price: '₹1,499',
            ),
            const SizedBox(height: 12),
            _buildServiceItem(
              icon: Icons.battery_charging_full,
              title: 'Eco-Battery Install',
              subtitle: 'Smart storage setup',
              price: '₹3,999',
              isPopular: true,
            ),
            const SizedBox(height: 32),

            // Feedback
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RECENT FEEDBACK', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                TextButton(
                  onPressed: () {},
                  child: const Text('VIEW ALL', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                )
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB6o5AT62Cj2BxlMIGcqFkIFxa_m4R-lXe7WrZOKnF5tE5lp8CxasOjO4YbXtkaoBeZtZe4pAD2w2UQMljcykVyfJ7Axd_5kYwYRT367BQ4tXDFnRMU_Uu0mXvGIt-r-BMxB7EMrFwbrSL1kOuTzPJ8qQ7peN_Xz5K_ngrlcINzzNgjhbyC0UHlFT63zMdKdGwwDhaZGRu3mJUuR_rui7eU4wS3u_qC4o_6KDZoIYcM4Bq--xXpPB_af5OsaibhAGUViXmFNWaYKVM'),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Sarah Mitchell', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w900, fontSize: 12)),
                          Text('2 days ago', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '"Rajesh optimized my solar grid in under 2 hours. My daily generation jumped by 15% immediately. Truly a master of his craft."',
                    style: TextStyle(color: AppColors.onSurface.withValues(alpha: 0.8), fontSize: 13, height: 1.5, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(5, (index) => const Icon(Icons.star, color: AppColors.primary, size: 12)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor ?? AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildServiceItem({required IconData icon, required String title, required String subtitle, required String price, bool isPopular = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPopular ? AppColors.tertiary.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isPopular ? AppColors.tertiary : AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
                    if (isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
                      )
                    ]
                  ],
                ),
                Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Text(price, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }
}
