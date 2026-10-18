import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/location_provider.dart';
import '../data/models/address_model.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final addresses = locationProvider.savedAddresses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Addresses',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement 'Add Address' flow
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Address coming soon')),
              );
            },
            icon: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary),
          ),
        ],
      ),
      body: addresses.isEmpty
          ? const _EmptyAddressesState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final address = addresses[index];
                final isSelected = locationProvider.currentAddress?.id == address.id;

                return _buildAddressItem(context, address, isSelected, locationProvider);
              },
            ),
    );
  }

  Widget _buildAddressItem(
    BuildContext context, 
    AddressModel address, 
    bool isSelected, 
    LocationProvider locationProvider,
  ) {
    return GestureDetector(
      onTap: () {
        locationProvider.selectAddress(address);
        Navigator.pop(context); // Go back to cart or prior screen
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : const Color(0xFF1E2228),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForLabel(address.label),
                color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullDisplay,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.circle_outlined, color: Colors.white.withValues(alpha: 0.2), size: 24),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    if (label.toLowerCase().contains('home')) return Icons.home_rounded;
    if (label.toLowerCase().contains('work') || label.toLowerCase().contains('office')) return Icons.work_rounded;
    return Icons.location_on_rounded;
  }
}

class _EmptyAddressesState extends StatelessWidget {
  const _EmptyAddressesState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No saved addresses',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your home or work address\nfor faster booking',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Address coming soon')),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'Add Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
