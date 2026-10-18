import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../providers/wallet_provider.dart';
import 'receipt_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final balance = walletProvider.balance;
    final transactions = walletProvider.transactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Hero
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 32, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ECO POINTS BALANCE', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        NumberFormat('#,##0.00').format(balance),
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                      ),
                      const SizedBox(width: 8),
                      const Text('PTS', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showTopUpDialog(context);
                          },
                          icon: const Icon(Icons.add_circle, size: 20),
                          label: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Withdrawals currently disabled for Eco Points.')),
                            );
                          },
                          icon: const Icon(Icons.payments, size: 20),
                          label: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
                            backgroundColor: AppColors.surfaceContainerHighest,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Recent Activity', style: TextStyle(color: AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.w900)),
                Text('View All', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
              ],
            ),
            const SizedBox(height: 16),

            if (transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No transactions yet', style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              ...transactions.map((tx) {
                final dateStr = DateFormat('MMM d, yyyy • HH:mm').format(tx.date);
                final amountStr = '${tx.isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(2)}';
                final icon = tx.isCredit ? Icons.account_balance_wallet : Icons.shopping_cart;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildTransactionItem(
                    context, 
                    icon, 
                    tx.title, 
                    dateStr, 
                    amountStr, 
                    'Success', 
                    tx.isCredit
                  ),
                );
              }),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _showTopUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainer,
          title: const Text('Top Up Eco Points', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          content: const Text('Add 500 Eco Points for mock testing?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<WalletProvider>().addFunds(500.0, title: 'Quick Top Up', subtitle: 'Mock Payment');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added 500 Eco Points successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
              child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, IconData icon, String title, String date, String amount, String status, bool isPositive, {bool isPending = false}) {
    Color iconColor = isPending ? AppColors.tertiary : (isPositive ? AppColors.primary : AppColors.onSurface);
    Color statusBgColor = isPending ? AppColors.tertiary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1);
    Color statusTextColor = isPending ? AppColors.tertiary : AppColors.primary;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(
              icon: icon,
              title: title,
              date: date,
              amount: amount,
              status: status,
              isPositive: isPositive,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isPending ? AppColors.tertiaryContainer.withValues(alpha: 0.2) : (isPositive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondaryContainer),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(date, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: TextStyle(color: isPending ? AppColors.tertiary : (isPositive ? AppColors.primary : Colors.white), fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status.toUpperCase(), style: TextStyle(color: statusTextColor, fontSize: 10, fontWeight: FontWeight.w900)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
