import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import 'worker_otp_screen.dart';

class WorkerPhoneScreen extends StatefulWidget {
  const WorkerPhoneScreen({super.key});

  @override
  State<WorkerPhoneScreen> createState() => _WorkerPhoneScreenState();
}

class _WorkerPhoneScreenState extends State<WorkerPhoneScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  Future<void> _send() async {
    final phone = _ctrl.text.trim();
    if (phone.isEmpty) return;
    setState(() => _loading = true);
    try {
      await context.read<WorkerProvider>().requestOtp(phone);
      if (!mounted) return;
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => WorkerOtpScreen(phone: phone)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.engineering, size: 72, color: Color(0xFF1565C0)),
              const SizedBox(height: 16),
              Text('Ecomins Worker',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 48),
              TextField(
                controller: _ctrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _send,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
