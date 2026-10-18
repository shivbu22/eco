import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Secure Checkout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Safe Security Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.security_rounded, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '100% Secure & RBI Compliant',
                      style: TextStyle(
                        color: Colors.green.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // OzoMin Wallet
            _buildSectionTitle('OzoMin Wallet'),
            const SizedBox(height: 12),
            _buildWalletCard(),
            const SizedBox(height: 32),

            // UPI Section
            _buildSectionTitle('UPI Apps'),
            const SizedBox(height: 12),
            _buildUpiGrid(),
            const SizedBox(height: 24),
            _buildPaymentOption(
              title: 'Add new UPI ID',
              subtitle: 'Google Pay, PhonePe, Paytm, etc.',
              icon: Icons.add_circle_outline_rounded,
              iconColor: Colors.white,
            ),
            const SizedBox(height: 32),

            // Credit & Debit Cards
            _buildSectionTitle('Credit & Debit Cards'),
            const SizedBox(height: 12),
            _buildSavedCard(
              bank: 'HDFC Bank',
              type: 'RuPay Credit Card',
              last4: '4123',
              iconData: Icons.credit_card_rounded,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              title: 'Add New Card',
              subtitle: 'Save and pay via Cards',
              icon: Icons.add_card_rounded,
              iconColor: Colors.white,
            ),
            const SizedBox(height: 32),

            // Other Methods
            _buildSectionTitle('Other Options'),
            const SizedBox(height: 12),
            _buildPaymentOption(
              title: 'Net Banking',
              subtitle: 'All major Indian banks supported',
              icon: Icons.account_balance_rounded,
              iconColor: Colors.blueAccent,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              title: 'Cash on Delivery (Eco-fee applies)',
              subtitle: 'Pay directly to the professional',
              icon: Icons.payments_rounded,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 48),
            
            // Footer Trust
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTrustBadge('PCI DSS\nCOMPLIANT', Icons.verified_user_rounded),
                const SizedBox(width: 24),
                _buildTrustBadge('AES 256\nENCRYPTION', Icons.enhanced_encryption_rounded),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '₹ 0.00',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('TOP UP', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildUpiGrid() {
    final upiApps = [
      {'name': 'GPay', 'color': Colors.blue},
      {'name': 'PhonePe', 'color': Colors.purple},
      {'name': 'Paytm', 'color': Colors.lightBlue},
      {'name': 'BHIM', 'color': Colors.orange},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: upiApps.map((app) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Icon(Icons.qr_code_2_rounded, color: app['color'] as Color, size: 28),
                const SizedBox(height: 8),
                Text(
                  app['name'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSavedCard({required String bank, required String type, required String last4, required IconData iconData}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                ),
                Text(
                  '$type ending in $last4',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.white54),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({required String title, required String subtitle, required IconData icon, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white54),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 28),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
