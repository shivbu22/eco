import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../profile/profile_screen.dart';
import 'booking_provider.dart';

/// A 3-step booking flow screen.
///
/// Requires a [BookingProvider] to be present in the widget tree above it.
/// Callers that don't already have one in the tree should wrap with
/// [ChangeNotifierProvider<BookingProvider>] before pushing this route.
class BookingScreen extends StatefulWidget {
  final String categoryId;
  final String categoryLabel;
  final List<String> subServices;
  /// Used in tests to start at a specific step without going through prior steps.
  @visibleForTesting
  final int initialStep;

  const BookingScreen({
    super.key,
    required this.categoryId,
    required this.categoryLabel,
    required this.subServices,
    this.initialStep = 0,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
  }
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _onContinue(BookingProvider booking) async {
    if (_step == 0) {
      if (booking.selectedSubService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select a service')));
        return;
      }
      await booking.fetchPrice(widget.categoryId, 'zone-1');
      if (mounted) setState(() => _step = 1);
    } else if (_step == 1) {
      if (_addressCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter your address')));
        return;
      }
      booking.address = _addressCtrl.text.trim();
      if (mounted) setState(() => _step = 2);
    } else {
      final auth = context.read<AuthProvider>();
      if (!auth.hasProfile) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        return;
      }
      final idToken = await auth.token ?? '';
      await booking.createJob(
        token: idToken,
        customerId: auth.customerId,
        serviceType: widget.categoryId,
        address: booking.address,
        zoneId: 'zone-1',
        price: booking.estimatedPrice ?? 500,
      );
      if (!mounted) return;
      if (booking.status == BookingStatus.success) {
        _showSuccess(booking.activeJobId!);
      } else if (booking.status == BookingStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(booking.errorMessage ?? 'Booking failed')));
      }
    }
  }

  void _showSuccess(String jobId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 56),
        title: const Text('Booking Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('A worker is being assigned to your job.'),
            const SizedBox(height: 8),
            Text('Job ID: ${jobId.substring(0, 8)}...',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to services
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) booking.reset();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.categoryLabel)),
        body: Column(
          children: [
            // Fallback price warning banner
            if (booking.priceFallback)
              MaterialBanner(
                backgroundColor: const Color(0xFFFFF3E0),
                content: const Text(
                  'Pricing unavailable — using default ₦500',
                  style: TextStyle(color: Color(0xFFE65100)),
                ),
                leading: const Icon(Icons.warning_amber,
                    color: Color(0xFFE65100)),
                actions: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('OK'),
                  ),
                ],
              ),
            Expanded(
              child: Stepper(
                currentStep: _step,
                controlsBuilder: (context, details) => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      FilledButton(
                        onPressed: booking.isLoading
                            ? null
                            : () => _onContinue(booking),
                        child: booking.isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(_step == 2
                                ? 'Confirm Booking'
                                : 'Continue'),
                      ),
                      const SizedBox(width: 12),
                      if (_step > 0)
                        TextButton(
                            onPressed: () {
                              if (_step > 0) setState(() => _step--);
                            },
                            child: const Text('Back')),
                    ],
                  ),
                ),
                onStepContinue: () => _onContinue(booking),
                onStepCancel: () {
                  if (_step > 0) setState(() => _step--);
                },
                steps: [
                  // Step 0 — Select service
                  Step(
                    title: const Text('Select Service'),
                    isActive: _step >= 0,
                    state:
                        _step > 0 ? StepState.complete : StepState.indexed,
                    content: Column(
                      children: widget.subServices
                          .map((s) => RadioListTile<String>(
                                title: Text(s),
                                value: s,
                                groupValue: booking.selectedSubService,
                                onChanged: booking.selectSubService,
                              ))
                          .toList(),
                    ),
                  ),
                  // Step 1 — Address + price
                  Step(
                    title: const Text('Location & Price'),
                    isActive: _step >= 1,
                    state:
                        _step > 1 ? StepState.complete : StepState.indexed,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Service address',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (booking.status == BookingStatus.fetchingPrice)
                          const Center(child: CircularProgressIndicator())
                        else if (booking.estimatedPrice != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.payments,
                                    color: Color(0xFF2E7D32)),
                                const SizedBox(width: 12),
                                const Text('Estimated price',
                                    style: TextStyle(color: Colors.grey)),
                                const Spacer(),
                                Text(
                                    '₦${booking.estimatedPrice!.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color(0xFF2E7D32))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Step 2 — Confirm summary
                  Step(
                    title: const Text('Confirm'),
                    isActive: _step >= 2,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row('Service',
                            booking.selectedSubService ?? ''),
                        _row('Category', widget.categoryLabel),
                        _row('Address', booking.address),
                        _row('Price',
                            '₦${booking.estimatedPrice?.toStringAsFixed(0) ?? "—"}'),
                        _row('Zone', 'Zone 1'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 80,
                child: Text(label,
                    style: const TextStyle(color: Colors.grey))),
            Expanded(
                child: Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );
}
