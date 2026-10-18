import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderIcon(),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Total Transparency',
              content:
                  'We safeguard your digital footprint as fiercely as we protect our physical environment. Your privacy is a fundamental human right. We collect only what is strictly mathematically necessary to provide you with seamless eco-friendly services.',
              icon: Icons.shield_rounded,
              isHighlight: true,
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. What We Collect',
              content:
                  '• Identity Data (Name, Phone number for OTP verification)\n• Geolocation (Strictly during active bookings to guide our eco-warriors)\n• Transaction Metadata (To process secure UPI and card payments securely)\n• Environmental Impact Data (Anonymized analytics to measure global societal health improvements)',
              icon: Icons.data_object_rounded,
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '2. How Your Data is Used',
              content:
                  'Your data is engineered solely for your benefit. We use it to route eco-services to your doorstep, secure your payments via RBI-approved payment gateways, and dynamically calculate your personal carbon offsets. We do NOT sell your data to third-party ad networks. Ever.',
              icon: Icons.auto_graph_rounded,
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '3. Data Sovereignty & Localization',
              content:
                  'In stringent compliance with the Digital Personal Data Protection Act of India, your data is quantum-encrypted and rests securely in geographically localized data centers within India. You have absolute sovereignty: you may view, port, or permanently obliterate your account data at any time via Settings.',
              icon: Icons.cloud_done_rounded,
            ),
             const SizedBox(height: 24),
            _buildSection(
              title: '4. Zero-Trust Security Architecture',
              content:
                  'We employ a Zero-Trust security model. Internal access requires rigorous multi-factor authentication, ensuring that your identifiable data remains completely inaccessible to human eyes without explicitly audited and monitored necessity.',
              icon: Icons.enhanced_encryption_rounded,
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Protecting your digital world to heal the physical one.\nOzoMin Data Protection Officer: dpo@ozomin.in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3), width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.fingerprint_rounded,
          color: AppColors.secondary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.secondary.withValues(alpha: 0.05) : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighlight ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isHighlight ? AppColors.secondary : AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
