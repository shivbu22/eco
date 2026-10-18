import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/wallet_provider.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; // 0: UPI, 1: Card, 2: OzoCoins
  bool _isProcessing = false;

  void _processPayment() async {
    final wallet = context.read<WalletProvider>();
    
    if (_selectedMethod == 5) {
      if (wallet.balance < widget.amount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient Eco Points balance. Please top up or choose another method.')),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);
    
    // Simulate real gateway processing
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      if (_selectedMethod == 5) {
        wallet.deductFunds(
          widget.amount, 
          title: 'Service Booking', 
          subtitle: 'Paid with Eco Points'
        );
      }
      widget.onPaymentSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = context.watch<WalletProvider>().balance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Payment', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBillSummary(),
                    const SizedBox(height: 32),
                    
                    const Text('UPI Options', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildPaymentOption(0, 'Google Pay', 'pays_via_gpay.png', Icons.contactless_outlined),
                    _buildPaymentOption(1, 'PhonePe', 'pays_via_phonepe.png', Icons.account_balance_wallet),
                    _buildPaymentOption(2, 'Paytm UPI', 'pays_via_paytm.png', Icons.qr_code_scanner),

                    const SizedBox(height: 24),
                    const Text('Cards & Netbanking', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildPaymentOption(3, 'Credit / Debit Card', null, Icons.credit_card),
                    _buildPaymentOption(4, 'Netbanking', null, Icons.account_balance),
                    
                    const SizedBox(height: 24),
                    const Text('Ozo Ecosystem', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      5, 
                      'Eco Points Wallet (Bal: ${walletBalance.toStringAsFixed(0)} PTS)', 
                      null, 
                      Icons.eco, 
                      subtitle: 'Use your earned points to pay',
                    ),
                    
                    const SizedBox(height: 40),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_rounded, color: Colors.green[400], size: 16),
                          const SizedBox(width: 8),
                          Text('100% Secure Payments', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomPayBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.15), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('Amount Payable', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '\$${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(color: AppColors.primary, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Includes all taxes & fees', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: const Text('Verified', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int index, String title, String? assetPath, IconData defaultIcon, {String? subtitle}) {
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
              child: Icon(defaultIcon, color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isSelected ? AppColors.primary : Colors.white, fontSize: 15, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.8), fontSize: 12)),
                  ]
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.5), width: 2),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPayBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: GestureDetector(
        onTap: _isProcessing ? null : _processPayment,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(28)),
          child: Center(
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                : Text('Proceed to Pay \$${widget.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
