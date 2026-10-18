import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../data/models/service_model.dart';
import '../providers/cart_provider.dart';
import '../components/shared_widgets.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with TickerProviderStateMixin {
  int _selectedOptionIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final service = widget.service;
    final isInCart = cart.isInCart(service.id);
    final selectedOption = service.options.isNotEmpty
        ? service.options[_selectedOptionIndex]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── HERO IMAGE ────────────────────────────────
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.background,
              leading: BounceWidget(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (service.image != null)
                      Image.asset(
                        service.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: const Color(0xFF252A2E),
                          child: Center(
                            child: Text(service.emoji,
                                style: const TextStyle(fontSize: 80)),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: const Color(0xFF252A2E),
                        child: Center(
                          child: Text(service.emoji,
                              style: const TextStyle(fontSize: 80)),
                        ),
                      ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.background.withValues(alpha: 0.5),
                            AppColors.background,
                          ],
                          stops: const [0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── CONTENT ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tags row
                    if (service.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: service.tags
                            .map((tag) => StatusBadge(
                                  text: tag,
                                  color: tag.contains('⭐')
                                      ? const Color(0xFFFFB74D)
                                      : AppColors.primary,
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      service.displayTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rating + Duration row
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFB74D), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${service.rating}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Icon(Icons.schedule_rounded,
                            color: Colors.white.withValues(alpha: 0.4), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          service.duration,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.eco_rounded,
                                  color: AppColors.primary, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'Eco Score ${service.ecoScore}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ─── AVAILABILITY ─────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: service.isAvailableNow
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : const Color(0xFFFFB74D).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: service.isAvailableNow
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : const Color(0xFFFFB74D).withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            service.isAvailableNow
                                ? Icons.bolt_rounded
                                : Icons.schedule_rounded,
                            color: service.isAvailableNow
                                ? AppColors.primary
                                : const Color(0xFFFFB74D),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            service.isAvailableNow
                                ? 'Available Now • Service in ~10 min'
                                : 'Next available: ${service.nextAvailableSlot ?? 'Soon'}',
                            style: TextStyle(
                              color: service.isAvailableNow
                                  ? AppColors.primary
                                  : const Color(0xFFFFB74D),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ─── SELECT OPTION ────────────────────────
                    if (service.options.isNotEmpty) ...[
                      const Text(
                        'Select Option',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(service.options.length, (index) {
                        final option = service.options[index];
                        final isSelected = index == _selectedOptionIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: BounceWidget(
                            onTap: () =>
                                setState(() => _selectedOptionIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : const Color(0xFF1E2228),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.4)
                                      : Colors.white.withValues(alpha: 0.06),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.white.withValues(alpha: 0.2),
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check_rounded,
                                            color: Colors.black, size: 14)
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      option.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    option.price == 0
                                        ? 'FREE'
                                        : '₹${option.price.toInt()}',
                                    style: TextStyle(
                                      color: option.price == 0
                                          ? AppColors.primary
                                          : Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 28),
                    ],

                    // ─── ECO IMPACT ───────────────────────────
                    if (service.ecoImpact.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.eco_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Eco Impact',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: service.ecoImpact
                            .map((impact) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                            AppColors.primary.withValues(alpha: 0.12)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppColors.primary, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        impact,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // ─── BOTTOM ACTION BAR ─────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1E22),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            // Price
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  selectedOption?.price == 0
                      ? 'FREE'
                      : '₹${selectedOption?.price.toInt() ?? service.basePrice.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // Add to cart button
            Expanded(
              child: BounceWidget(
                onTap: () {
                  if (selectedOption != null) {
                    if (isInCart) {
                      cart.removeService(service.id);
                    } else {
                      cart.addService(service, selectedOption);
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isInCart
                        ? null
                        : const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF2ECC71)],
                          ),
                    color: isInCart ? Colors.white.withValues(alpha: 0.1) : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isInCart
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isInCart
                              ? Icons.remove_shopping_cart_rounded
                              : Icons.add_shopping_cart_rounded,
                          color: isInCart ? Colors.white70 : Colors.black,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isInCart ? 'Remove from Cart' : 'Add to Cart',
                          style: TextStyle(
                            color: isInCart ? Colors.white70 : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
