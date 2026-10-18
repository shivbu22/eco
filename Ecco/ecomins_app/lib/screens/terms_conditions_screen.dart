import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Terms & Conditions',
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
              title: 'Our Covenant with the Earth',
              content:
                  'We believe that modern technology and ancient wisdom must coalesce to heal our planet. By using OzoMin, you enter into a covenant not just with us, but with nature. We pledge to deliver verifiable eco-services, and you pledge to utilize them responsibly.',
              icon: Icons.eco_rounded,
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. Acceptance of Terms',
              content:
                  'By creating an account, accessing the OzoMin app, or booking our services, you mathematically and legally bind yourself to these terms. If you disagree with any part of these terms, you may not access our holistic ecosystems.',
              icon: Icons.gavel_rounded,
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '2. Scientific Validation & Eco-Impact',
              content:
                  'The carbon offsets and water savings calculated in this app are rooted in peer-reviewed scientific data and verified by third-party ecological auditors. While we strive for extreme accuracy, these metrics are estimates meant to inspire and guide sustainable action.',
              icon: Icons.science_rounded,
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '3. Payments & Secure Transactions',
              content:
                  'OzoMin adheres to the highest level of financial security protocols (PCI-DSS) and adheres strictly to RBI guidelines for Indian transactions (UPI, RuPay, Wallets). All transactions are encrypted with AES-256 military-grade security. Refunds are processed empathetically within 5-7 business days for unfulfilled services.',
              icon: Icons.security_rounded,
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '4. Service Quality & Dispute Resolution',
              content:
                  'We orchestrate a network of the finest eco-warriors (service professionals). If a service fails to meet our stringent ecological and quality standards, our empathetic support team will resolve it within 24 hours. We prioritize harmony over bureaucracy.',
              icon: Icons.handshake_rounded,
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Last Updated: April 2026\nOzoMin Technologies Pvt. Ltd.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
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
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
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
