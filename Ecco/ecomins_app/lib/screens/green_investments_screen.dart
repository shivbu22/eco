import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GreenInvestmentsScreen extends StatelessWidget {
  const GreenInvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.onSurface, size: 20),
        ),
        title: const Text('Green Investments', style: TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.surfaceContainerLow, AppColors.surfaceContainerLowest],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Portfolio Value', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text('\$1,245.50', style: TextStyle(color: AppColors.onSurface, fontSize: 36, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Text('+12.4%', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn('Asset Types', '3'),
                      _buildStatColumn('CO2 Prevented', '2.4 tons'),
                      _buildStatColumn('Next Payout', '12 days'),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            const Text('Investment Opportunities', style: TextStyle(color: AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildInvestmentCard(
              title: 'Desert Solar Array (Fund VI)',
              type: 'Renewable Energy',
              apy: '8.5% APY',
              progress: 0.75,
              color: AppColors.tertiary,
            ),
            const SizedBox(height: 16),
            _buildInvestmentCard(
              title: 'Ocean Plastic Cleanup Tech',
              type: 'Innovation & Hardware',
              apy: '12.0% APY',
              progress: 0.45,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            _buildInvestmentCard(
              title: 'Community Bio-Fuels',
              type: 'Local Infrastructure',
              apy: '6.2% APY',
              progress: 0.90,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInvestmentCard({required String title, required String type, required String apy, required double progress, required Color color}) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(type, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              Text(apy, style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toInt()}% Funded', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
              Text('Ends in 4 days', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
