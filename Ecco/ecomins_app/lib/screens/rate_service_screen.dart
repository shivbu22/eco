import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RateServiceScreen extends StatefulWidget {
  final String workerName;
  final String workerAvatar;

  const RateServiceScreen({
    super.key,
    this.workerName = 'Eco-Technician Marcus',
    this.workerAvatar = '👨‍🔧',
  });

  @override
  State<RateServiceScreen> createState() => _RateServiceScreenState();
}

class _RateServiceScreenState extends State<RateServiceScreen>
    with SingleTickerProviderStateMixin {
  int _rating = 4;
  final Set<String> _selectedStrengths = {'Professional', 'Punctual', 'Eco-conscious'};
  final TextEditingController _reviewController = TextEditingController();
  late AnimationController _animController;

  final List<String> _strengths = [
    'Professional', 'Punctual', 'Eco-conscious', 'Thorough', 'Efficient',
  ];

  final List<String> _ratingLabels = [
    '', 'POOR', 'FAIR', 'GOOD', 'GREAT EXPERIENCE', 'OUTSTANDING',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('ECO-FLOW',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                letterSpacing: 1, color: AppColors.primary)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // ── Worker Avatar ──
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.2), AppColors.surfaceContainerHigh],
                ),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4), width: 2),
              ),
              child: Center(
                child: Text(widget.workerAvatar, style: const TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 4),
            // Verified badge
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: Icon(Icons.check, color: AppColors.onPrimary, size: 14),
            ),
            const SizedBox(height: 16),
            const Text('HOW WAS THE FLOW?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text(
              'Your feedback drives our zero-emission mission. Rate your recent session with ${widget.workerName}.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 28),

            // ── Star Rating ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final filled = i < _rating;
                      return GestureDetector(
                        onTap: () => setState(() => _rating = i + 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            filled ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 48,
                            color: filled ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text(_ratingLabels[_rating],
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                          letterSpacing: 1.5, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Strengths ──
            Align(
              alignment: Alignment.centerLeft,
              child: Text('HIGHLIGHT STRENGTHS',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      letterSpacing: 1, color: Colors.white)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _strengths.map((s) {
                final isSelected = _selectedStrengths.contains(s);
                return GestureDetector(
                  onTap: () => setState(() {
                    isSelected ? _selectedStrengths.remove(s) : _selectedStrengths.add(s);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: Text(s,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // ── Review Text ──
            Align(
              alignment: Alignment.centerLeft,
              child: Text('SHARE YOUR EXPERIENCE',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      letterSpacing: 1, color: AppColors.primary)),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _reviewController,
                maxLines: 4,
                maxLength: 500,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Describe the service quality or any suggestions for improvement...',
                  hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit Button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Review submitted! Thank you for your feedback.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('SUBMIT REVIEW',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('MAYBE LATER',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: Colors.white, letterSpacing: 0.5)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
