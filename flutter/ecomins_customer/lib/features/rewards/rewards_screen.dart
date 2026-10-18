import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import 'rewards_provider.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final idToken = await auth.token ?? '';
      if (mounted) {
        context.read<RewardsProvider>().loadRewards(idToken, auth.customerId);
      }
    });
  }

  void _showRedeemDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Redeem Points'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Points to redeem',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final amount = int.tryParse(controller.text);
                if (amount == null || amount <= 0) return;

                final auth = context.read<AuthProvider>();
                final rewards = context.read<RewardsProvider>();
                final idToken = await auth.token ?? '';
                final success = await rewards.redeemPoints(
                    idToken, auth.customerId, amount);

                if (!context.mounted) return;
                Navigator.pop(ctx);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Points redeemed successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(rewards.errorMessage ?? 'Redemption failed')),
                  );
                }
              },
              child: const Text('Redeem'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rewards = context.watch<RewardsProvider>();

    if (rewards.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            color: const Color(0xFF2E7D32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.eco, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    '${rewards.pointsBalance}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Eco Points',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text('Eco Score'),
              trailing: Text(
                '${rewards.ecoScore}',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showRedeemDialog(context),
            icon: const Icon(Icons.redeem),
            label: const Text('Redeem Points'),
          ),
          const SizedBox(height: 16),
          Text(
            'Earn points by booking eco-friendly services',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
