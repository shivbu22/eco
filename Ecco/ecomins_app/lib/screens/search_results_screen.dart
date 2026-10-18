import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/services_provider.dart';
import '../data/models/service_model.dart';
import 'service_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchResultsScreen({super.key, this.initialQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    // Trigger initial search if query provided
    Future.microtask(() {
      if (!mounted) return;
      if (widget.initialQuery != null) {
        context.read<ServicesProvider>().search(widget.initialQuery!);
      } else {
        context.read<ServicesProvider>().search('');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ServicesProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                        onPressed: () {
                          provider.search(''); // Clear search on back
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Search',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        backgroundImage: const NetworkImage(
                            'https://api.dicebear.com/7.x/avataaars/png?seed=Felix'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      provider.search(value);
                      setState(() {}); // Update local state for clear button visibility
                    },
                    autofocus: widget.initialQuery == null,
                    decoration: InputDecoration(
                      hintText: 'Search eco-services...',
                      hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchController.text.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              provider.search('');
                              setState(() {});
                            },
                          )
                        : null,
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    ),
                    style: const TextStyle(color: AppColors.onSurface),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (provider.searchQuery.isEmpty) ...[
                          // Categories Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Categories',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.onSurface, letterSpacing: -1.0),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'VIEW ALL',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              _buildCategoryCard(provider, 'Cleaning', 'Sustainable deep cleaning', Icons.cleaning_services, true),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCategoryCard(provider, 'Waste', 'Zero-waste removal', Icons.delete, false),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildCategoryCard(provider, 'Recycling', 'Smart sorting', Icons.recycling, false),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Results Header
                        Text(
                          provider.searchQuery.isEmpty ? 'Recommended' : 'Search Results (${provider.serviceCount})',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.onSurface, letterSpacing: -1.0),
                        ),
                        const SizedBox(height: 16),
                        
                        // Service Cards
                        if (provider.services.isEmpty)
                          _buildNoResults(provider)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.services.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _buildSpecialistCard(context, provider.services[index]);
                            },
                          ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoResults(ServicesProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          const Text(
            'No matching services',
            style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find anything matching "${provider.searchQuery}"',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              context.read<ServicesProvider>().search('');
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear Search'),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ServicesProvider provider, String title, String subtitle, IconData icon, bool isFullWidth) {
    return GestureDetector(
      onTap: () => provider.selectCategory(title),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -24,
              bottom: -24,
              child: Icon(
                icon,
                size: isFullWidth ? 120 : 80,
                color: AppColors.onSurfaceVariant.withValues(alpha: isFullWidth ? 0.05 : 0.08),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.primary, size: 32),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(color: AppColors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistCard(BuildContext context, ServiceModel service) {
    final isPremium = service.rating >= 4.8;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
        boxShadow: isPremium ? [
           BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 0)
        ] : [],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(service.emoji, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service.title.replaceAll('\n', ' '),
                            style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: AppColors.primary, size: 12),
                              const SizedBox(width: 4),
                              Text('${service.rating}', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Eco Score: ${service.ecoScore}% • ${service.category}',
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          service.duration.toUpperCase(),
                          style: const TextStyle(color: AppColors.onSurface, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                        if (service.isAvailableNow) ...[
                          const SizedBox(width: 12),
                          Container(width: 4, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant.withValues(alpha: 0.4), shape: BoxShape.circle)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('AVAILABLE NOW', style: TextStyle(color: AppColors.tertiaryContainer, fontSize: 8, fontWeight: FontWeight.w900)),
                          )
                        ]
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.outlineVariant, thickness: 0.2),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EST. PRICE', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text(
                    service.basePrice == 0 ? 'FREE' : '₹${service.basePrice.toInt()}', 
                    style: const TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w900)
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => ServiceDetailScreen(service: service)
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: service.isAvailableNow ? AppColors.primary : AppColors.surfaceContainerHighest,
                  foregroundColor: service.isAvailableNow ? AppColors.onPrimary : AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: service.isAvailableNow ? 8 : 0,
                  shadowColor: AppColors.primary.withValues(alpha: 0.5),
                ),
                child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }
}
