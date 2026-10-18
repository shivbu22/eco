import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class BookingFlowScreen extends StatefulWidget {
  final String category;
  const BookingFlowScreen({super.key, required this.category});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final _addressCtrl = TextEditingController();
  bool _loading = false;
  double? _price;
  int _step = 0; // 0=address, 1=price, 2=confirm

  @override
  void initState() {
    super.initState();
    _fetchPrice();
  }

  Future<void> _fetchPrice() async {
    try {
      final result = await ApiService.getPrice(
        widget.category.toLowerCase().replaceAll(' ', '_'),
        'zone-1',
      );
      setState(() => _price = (result['total'] as num?)?.toDouble() ?? 500.0);
    } catch (_) {
      setState(() => _price = 500.0);
    }
  }

  Future<void> _book() async {
    if (_addressCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final token = context.read<AuthProvider>().token!;
      await ApiService.createJob(
        token: token,
        serviceType: widget.category.toLowerCase().replaceAll(' ', '_'),
        lat: 6.5244,
        lng: 3.3792,
        address: _addressCtrl.text.trim(),
        zoneId: 'zone-1',
        customerId: 'cust-demo',
        price: _price ?? 500.0,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Booking confirmed! Worker on the way.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          if (_step == 0 && _addressCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter your address')),
            );
            return;
          }
          if (_step < 2) setState(() => _step++);
          if (_step == 2) _book();
        },
        onStepCancel: () {
          if (_step > 0) setState(() => _step--);
        },
        steps: [
          Step(
            title: const Text('Service Address'),
            isActive: _step >= 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter your address',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Step(
            title: const Text('Price'),
            isActive: _step >= 1,
            state: _step > 1 ? StepState.complete : StepState.indexed,
            content: _price == null
                ? const CircularProgressIndicator()
                : Card(
                    child: ListTile(
                      leading: const Icon(Icons.payments, color: Color(0xFF2E7D32)),
                      title: const Text('Estimated price'),
                      trailing: Text(
                        '₦${_price!.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ),
          ),
          Step(
            title: const Text('Confirm'),
            isActive: _step >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Service', widget.category),
                _infoRow('Address', _addressCtrl.text),
                _infoRow('Price', '₦${_price?.toStringAsFixed(0) ?? "—"}'),
                const SizedBox(height: 8),
                if (_loading) const LinearProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
                width: 70,
                child: Text(label,
                    style: const TextStyle(color: Colors.grey))),
            Expanded(
                child: Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );
}
