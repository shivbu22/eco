import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EcoRewardsMarketplaceScreen extends StatelessWidget {
  const EcoRewardsMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'OZOMIN MARKETPLACE',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceContainerHighest,
              backgroundImage: const NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuArK33dROKhhx_U-2Q3dOwhdnVTj33bXlk18KP9HpgxbW2tncx5CAVc2uSE9bIZgWH0udzcTOXPnrOk0L2G5EQE0XMVSWj1fZhsM41AldjuyUePC5RkKkaUI2-M1Weh46cLfDDLgxlsZTAjQHqgX02Gdmxt_VGcYnCxXB-eJnoeOA4549rvJu9kyvmBAw3VE-miBSEQAW0qnUC_A05XV7mjo-RCOBVtcUUXnd3ZG3L2jimyPlMiA0lszJs1sEHWsAYUWCJVwmEcI80'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Points Hero Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 20))
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Glow effects omitted for brevity/performance in simple box, but added a subtle inner shadow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURRENT BALANCE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            '12,450',
                            style: TextStyle(color: AppColors.onSurface, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -2.0, height: 1.0),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'EcoPoints',
                            style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "You're in the top 5% of earners this month. Keep going, Emerald Member!",
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.bolt, size: 20),
                        label: const Text('Boost Points'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', isSelected: true),
                  _buildFilterChip('Vouchers'),
                  _buildFilterChip('Eco-Products'),
                  _buildFilterChip('Brand Partners'),
                  _buildFilterChip('Flash Deals'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Product Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
              children: [
                _buildProductCard(
                  title: 'Bamboo Cutlery Set',
                  subtitle: 'Zero-waste travel companion.',
                  points: '1,200',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAKJtjeByOtej-90RjNnCp7B9fbPI_n6EcU90TKomi9V5F9cIB7j-u5TGYUQL-8JDHlnmPcnpG4UfXruoIEYxWv930rweYlj2EC_BWfDQezPndbIRE9hzccDc6MVYJcsKB3eocnPQC7WbU7XGPETaaNlY7hd1N4nTeTgEzZQ_70iPVXksxMTGVjlMP-DFFy78y9MxN97xXl9tyQyRQK3964NZWYSnjc6Xs4zl5BgugjeyIVNIAPEx06Y014nTl3HZOi8aE3ub8CqYY',
                  isFlash: true,
                ),
                _buildProductCard(
                  title: 'Solar Power Bank',
                  subtitle: '20,000mAh clean energy.',
                  points: '4,500',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAUcR9iIotb6U1V51Y-tkjp-bGcKE7WRrEdhxdORw2F5PPaHs_FaKBiwn_micIOfpPMT3CNZx1IMPh_pPSXIvh4XUyHEQy-jGKN6Z1ZOgLArtf86wvJiVtueO67Ifq5wm3hgGUricKxzx51IFNDN_N6RA9Sfk0uOhoA-rxxmOY7dkbJPPeg10tapkG-cR_9O6DGqwEwJ7kNQDNeFvEJIRWIpK3pXCvORN7EleS3tdWxjKpqqzydBUngVRKNXU4JtpdEy4RjBdZHddY',
                  isFlash: false,
                ),
                _buildProductCard(
                  title: 'Cleaning Kit',
                  subtitle: 'Biodegradable home care.',
                  points: '2,800',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAOIjvJidEY4MUNsqaiyoKhjgc4kWpbs0TvakF3702jYN7R0WsBP3tVTD8CPDGIz5wQ01zBbrJbzDuHRp7VRfzjm_OD4c5pUvE_DItIbK2TPZBhX0ncnKPD3uCbU8tLxOfZmZ9EMY0C_nkYix6HVi2zaNkD8lGviTX-oaBSExpvEzSqpc_eWsp2GrsDSE6LoCIC9_v7j5VuN7hgFRfythvbEmilC7t3yNItjhNoiVQtA1cpHe0_LqKUPI8CKLscn4gPmZcI4eOmWiU',
                  isFlash: false,
                ),
                _buildVoucherCard(),
              ],
            ),
            const SizedBox(height: 32),
            
            // Footer
            Center(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.history, size: 18),
                label: const Text('View Rewards History'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'OZOMIN ECOSYSTEM © 2024',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({required String title, required String subtitle, required String points, required String imageUrl, bool isFlash = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imageUrl, fit: BoxFit.cover),
                if (isFlash)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.tertiaryContainer, borderRadius: BorderRadius.circular(8)),
                      child: const Text('FLASH SALE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                    ),
                  )
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.eco, color: AppColors.primary, size: 12),
                          const SizedBox(width: 4),
                          Text(points, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Redeem', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVoucherCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFF191C19),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9900),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: const Color(0xFFFF9900).withValues(alpha: 0.3), blurRadius: 10)],
                    ),
                    child: const Icon(Icons.shopping_cart, color: Colors.white, size: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text('₹200 Amazon', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w900, fontSize: 14)),
                  const Text('DIGITAL VOUCHER', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Amazon Gift Card', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                      SizedBox(height: 4),
                      Text('Instant digital delivery.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10), maxLines: 2),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.eco, color: AppColors.primary, size: 12),
                          SizedBox(width: 4),
                          Text('3,200', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Redeem', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
