import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../booking/booking_provider.dart';
import '../booking/booking_screen.dart';

class _Category {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final List<String> subServices;

  const _Category({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.subServices,
  });
}

const _categories = [
  _Category(
    id: 'cleaning',
    label: 'Cleaning',
    icon: Icons.cleaning_services,
    color: Color(0xFF1565C0),
    subServices: ['Home Cleaning', 'Deep Cleaning', 'Office Cleaning', 'Eco Cleaning'],
  ),
  _Category(
    id: 'waste_management',
    label: 'Waste Management',
    icon: Icons.delete_outline,
    color: Color(0xFF6A1B9A),
    subServices: ['Garbage Pickup', 'Segregation', 'E-Waste Collection', 'Bulk Removal'],
  ),
  _Category(
    id: 'logistics',
    label: 'Logistics',
    icon: Icons.local_shipping,
    color: Color(0xFFE65100),
    subServices: ['Waste Transport', 'Truck Booking'],
  ),
  _Category(
    id: 'b2b',
    label: 'B2B Services',
    icon: Icons.business,
    color: Color(0xFF00695C),
    subServices: ['Society Waste Mgmt', 'Cleaning Contracts', 'Staff Outsourcing'],
  ),
  _Category(
    id: 'recycling',
    label: 'Recycling',
    icon: Icons.recycling,
    color: Color(0xFF2E7D32),
    subServices: ['Waste-to-Cash', 'Scrap Collection', 'Eco Rewards'],
  ),
];

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What do you need?',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Book a service in ≤15 minutes',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _CategoryCard(cat: _categories[i]),
              childCount: _categories.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _Category cat;
  const _CategoryCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => BookingProvider(),
              child: BookingScreen(
                categoryId: cat.id,
                categoryLabel: cat.label,
                subServices: cat.subServices,
              ),
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cat.color.withValues(alpha: 0.75), cat.color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(cat.icon, size: 44, color: Colors.white),
              const SizedBox(height: 10),
              Text(cat.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(height: 4),
              Text('${cat.subServices.length} services',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
