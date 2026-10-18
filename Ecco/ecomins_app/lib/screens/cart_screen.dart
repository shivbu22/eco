import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/location_provider.dart';
import '../providers/booking_provider.dart';
import '../components/shared_widgets.dart';
import 'booking_confirmed_screen.dart';
import 'saved_addresses_screen.dart';
import 'payment_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final location = context.watch<LocationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BounceWidget(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2228),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 20),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${cart.itemCount} ${cart.itemCount == 1 ? 'service' : 'services'}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () {
                cart.clearCart();
                Navigator.pop(context);
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyCart()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── DELIVERY ADDRESS ──────────────────────
                  _buildSectionTitle('Delivery Address'),
                  const SizedBox(height: 10),
                  _buildAddressCard(context, location),
                  const SizedBox(height: 24),

                  // ─── SCHEDULE ──────────────────────────────
                  _buildSectionTitle('Delivery Time'),
                  const SizedBox(height: 10),
                  _buildScheduleSelector(cart),
                  const SizedBox(height: 24),

                  // ─── CART ITEMS ────────────────────────────
                  _buildSectionTitle('Services'),
                  const SizedBox(height: 10),
                  ...cart.items.map((item) => _buildCartItem(item, cart)),
                  const SizedBox(height: 24),

                  // ─── PROMO CODE ────────────────────────────
                  _buildSectionTitle('Promo Code'),
                  const SizedBox(height: 10),
                  _buildPromoSection(cart),
                  const SizedBox(height: 24),

                  // ─── PRICE BREAKDOWN ───────────────────────
                  _buildPriceBreakdown(cart),
                ],
              ),
            ),
      bottomNavigationBar: cart.isNotEmpty ? _buildCheckoutBar(cart) : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              color: Colors.white.withValues(alpha: 0.15), size: 80),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add eco services and book in seconds',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, LocationProvider location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.areaName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  location.displayLocation,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          BounceWidget(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedAddressesScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSelector(CartProvider cart) {
    return Row(
      children: [
        Expanded(
          child: BounceWidget(
            onTap: () => cart.setAsap(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cart.isAsap
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : const Color(0xFF1E2228),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: cart.isAsap
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: cart.isAsap
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.4),
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ASAP',
                    style: TextStyle(
                      color: cart.isAsap ? AppColors.primary : Colors.white70,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '~10 min',
                    style: TextStyle(
                      color: cart.isAsap
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.3),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BounceWidget(
            onTap: () => _pickScheduleTime(cart),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: !cart.isAsap
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : const Color(0xFF1E2228),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: !cart.isAsap
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: !cart.isAsap
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.4),
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Schedule',
                    style: TextStyle(
                      color: !cart.isAsap ? AppColors.primary : Colors.white70,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    !cart.isAsap ? cart.estimatedTime : 'Pick time',
                    style: TextStyle(
                      color: !cart.isAsap
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.3),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(dynamic item, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF252A2E),
            ),
            child: item.service.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      item.service.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(item.service.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                  )
                : Center(
                    child: Text(item.service.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.service.displayTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.selectedOption.label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.subtotal == 0
                    ? 'FREE'
                    : '₹${item.subtotal.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              BounceWidget(
                onTap: () => cart.removeService(item.service.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      color: Color(0xFFFF5252),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: cart.promoCode != null
          ? Row(
              children: [
                const Icon(Icons.local_offer_rounded,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cart.promoCode!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'You save ₹${cart.promoDiscount.toInt()}',
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                BounceWidget(
                  onTap: () => cart.removePromo(),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white54, size: 20),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                BounceWidget(
                  onTap: () {
                    if (_promoController.text.isNotEmpty) {
                      cart.applyPromo(_promoController.text);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPriceBreakdown(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2228),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          _buildPriceRow('GST (18%)', '₹${cart.gst.toStringAsFixed(0)}'),
          const SizedBox(height: 10),
          _buildPriceRow(
            'Delivery Fee',
            cart.deliveryFee == 0
                ? 'FREE'
                : '₹${cart.deliveryFee.toStringAsFixed(0)}',
            highlight: cart.deliveryFee == 0,
          ),
          if (cart.promoDiscount > 0) ...[
            const SizedBox(height: 10),
            _buildPriceRow(
              'Promo Discount',
              '-₹${cart.promoDiscount.toStringAsFixed(0)}',
              highlight: true,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                '₹${cart.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(CartProvider cart) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E22),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: BounceWidget(
        onTap: () => _handleCheckout(cart),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF2ECC71)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
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
                const Icon(Icons.flash_on_rounded,
                    color: Colors.black, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Confirm • ₹${cart.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleCheckout(CartProvider cart) {
    if (cart.isEmpty) return;

    final bookingProvider = context.read<BookingProvider>();
    final location = context.read<LocationProvider>();

    if (location.currentAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    final items = List.of(cart.items);
    final totalAmount = cart.total;
    final scheduledTime = cart.scheduledTime;
    final currentAddress = location.currentAddress!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          amount: totalAmount,
          onPaymentSuccess: () {
            // Processing bookings only after successful payment
            for (final item in items) {
              bookingProvider.createBooking(
                serviceId: item.service.id,
                serviceName: item.service.displayTitle,
                serviceEmoji: item.service.emoji,
                serviceImage: item.service.image,
                selectedOption: item.selectedOption.label,
                subtotal: item.subtotal,
                gst: item.subtotal * 0.18,
                total: item.subtotal * 1.18,
                address: currentAddress,
                scheduledAt: scheduledTime,
                notes: item.notes,
              );
            }

            cart.clearCart();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BookingConfirmedScreen(totalAmount: totalAmount),
              ),
            );
          },
        ),
      ),
    );
  }

  void _pickScheduleTime(CartProvider cart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: Color(0xFF1E2228),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      final now = DateTime.now();
      cart.setScheduledTime(
          DateTime(now.year, now.month, now.day, time.hour, time.minute));
    }
  }
}
