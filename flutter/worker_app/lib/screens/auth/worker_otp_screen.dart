import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';

class WorkerOtpScreen extends StatefulWidget {
  final String phone;
  const WorkerOtpScreen({super.key, required this.phone});

  @override
  State<WorkerOtpScreen> createState() => _WorkerOtpScreenState();
}

class _WorkerOtpScreenState extends State<WorkerOtpScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  Future<void> _verify() async {
    final otp = _ctrl.text.trim();
    if (otp.length != 6) return;
    setState(() => _loading = true);
    try {
      await context.read<WorkerProvider>().verifyOtp(widget.phone, otp);
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
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Code sent to ${widget.phone}'),
            const SizedBox(height: 24),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _verify,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
