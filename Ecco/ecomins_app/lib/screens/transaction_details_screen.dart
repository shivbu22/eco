import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/database_service.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final String? transactionId;

  const TransactionDetailsScreen({super.key, this.transactionId});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final transactions = db.getTransactions();
    final txn = transactionId != null
        ? transactions.firstWhere((t) => t['id'] == transactionId, orElse: () => transactions.first)
        : transactions.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('OZOMIN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                letterSpacing: 2, color: AppColors.primary, fontStyle: FontStyle.italic)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.more_vert, color: AppColors.onSurfaceVariant), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Status Badge ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(txn['status'].toString().toUpperCase(),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          letterSpacing: 0.8, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Service Icon ──
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.15), Colors.transparent],
                ),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 2),
              ),
              child: Center(
                child: Text(txn['icon'], style: const TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            Text(txn['service'],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(txn['date'],
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 28),

            // ── Amount Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text('AMOUNT CHARGED',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          letterSpacing: 1, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${txn['amount'].toInt()}',
                          style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900,
                              color: AppColors.primary, height: 1)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(txn['currency'],
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                            letterSpacing: 0.8, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── CO2 Offset ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.surfaceContainer],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.eco_rounded, size: 28, color: AppColors.primary),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CO₂ IMPACT',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                              letterSpacing: 0.8, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text('${txn['co2Offset']} kg',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_down_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('OFFSET',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Detail Rows ──
            _detailRow('Transaction ID', txn['id']),
            _detailRow('Location', txn['location']),
            _detailRow('Payment Method', 'Eco Wallet'),
            _detailRow('Service Type', txn['service']),
            const SizedBox(height: 28),

            // ── Actions ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.receipt_outlined, size: 18),
                    label: const Text('RECEIPT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.report_outlined, size: 18),
                    label: const Text('DISPUTE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('REBOOK THIS SERVICE',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
          const Spacer(),
          Flexible(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
