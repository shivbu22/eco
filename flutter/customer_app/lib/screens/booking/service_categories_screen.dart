import 'package:flutter/material.dart';
import 'booking_flow_screen.dart';

const _categories = [
  {'icon': Icons.cleaning_services, 'label': 'Cleaning', 'color': Color(0xFF1565C0)},
  {'icon': Icons.delete_outline, 'label': 'Waste Management', 'color': Color(0xFF6A1B9A)},
  {'icon': Icons.local_shipping, 'label': 'Logistics', 'color': Color(0xFFE65100)},
  {'icon': Icons.business, 'label': 'B2B Services', 'color': Color(0xFF00695C)},
  {'icon': Icons.recycling, 'label': 'Recycling', 'color': Color(0xFF2E7D32)},
];

class ServiceCategoriesScreen extends StatelessWidget {
  const ServiceCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What do you need?',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                return _CategoryCard(
                  icon: cat['icon'] as IconData,
                  label: cat['label'] as String,
                  color: cat['color'] as Color,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingFlowScreen(
                          category: cat['label'] as String),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
