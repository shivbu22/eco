import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/database_service.dart';

class SmartHomeScreen extends StatefulWidget {
  const SmartHomeScreen({super.key});

  @override
  State<SmartHomeScreen> createState() => _SmartHomeScreenState();
}

class _SmartHomeScreenState extends State<SmartHomeScreen> {
  final DatabaseService _db = DatabaseService();
  late Map<String, dynamic> _data;
  int _chartView = 0; // 0=Solar, 1=Grid

  @override
  void initState() {
    super.initState();
    _data = _db.getSmartHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('OZOMIN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                letterSpacing: 2, color: AppColors.primary, fontStyle: FontStyle.italic)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('ECO-HOME AUTOMATION',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 1.5, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            const Text('Smart Home',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 20),

            // ── Impact Score + Live Power ──
            Row(
              children: [
                Expanded(child: _buildTopCard(
                  label: 'IMPACT SCORE',
                  value: '${_data['impactScore']}',
                  suffix: '/100',
                  color: AppColors.primary,
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildTopCard(
                  label: 'LIVE POWER',
                  value: '${_data['livePower']}',
                  suffix: 'kW',
                  color: AppColors.tertiary,
                )),
              ],
            ),
            const SizedBox(height: 12),
            // CO2 Today
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.surfaceContainer],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.eco_rounded, size: 28, color: AppColors.primary),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CO₂ Saved Today', style: TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                      Text('${_data['co2Today']} kg',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.trending_up_rounded, size: 28, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Devices Section ──
            const Text('Connected Devices',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 16),
            ...(_data['devices'] as List).map((d) => _buildDeviceCard(d)),
            const SizedBox(height: 28),

            // ── Energy Analytics ──
            const Text('Energy Analytics',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              children: [
                _chartToggle('Solar Gen', 0),
                const SizedBox(width: 16),
                _chartToggle('Grid Usage', 1),
              ],
            ),
            const SizedBox(height: 16),
            _buildEnergyChart(),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.savings_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NET SAVINGS THIS MONTH', style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text('₹${_data['netSavings']}',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Automation & Optimization ──
            Row(
              children: [
                Expanded(child: _buildCountCard(
                  icon: Icons.auto_awesome_rounded,
                  value: '${_data['activeAutomations']}',
                  label: 'Active\nAutomations',
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildCountCard(
                  icon: Icons.lightbulb_outline_rounded,
                  value: '${_data['pendingOptimizations']}',
                  label: 'Pending\nOptimizations',
                )),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard({
    required String label,
    required String value,
    required String suffix,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              letterSpacing: 0.8, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color, height: 1)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(suffix, style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final isWaste = device['type'] == 'waste';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(isWaste ? Icons.delete_outline_rounded : Icons.water_drop_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device['name'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    if (device['model'] != null)
                      Text(device['model'],
                          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (device['status'] == 'ONLINE' ? AppColors.primary : AppColors.tertiary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(device['status'] ?? device['alert'] ?? '',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: device['status'] == 'ONLINE' ? AppColors.primary : AppColors.tertiary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isWaste) ...[
            Row(
              children: [
                Text('FILL LEVEL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    letterSpacing: 0.8, color: AppColors.onSurfaceVariant)),
                const Spacer(),
                Text('${device['fillLevel']}%',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (device['fillLevel'] as int) / 100,
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(
                  (device['fillLevel'] as int) > 80 ? AppColors.tertiary : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('AUTO-COMPACT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
                const Spacer(),
                Switch(
                  value: device['autoCompact'] ?? false,
                  onChanged: (v) {},
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                _deviceMetric('MOISTURE', '${device['moisture']}%'),
                const SizedBox(width: 24),
                _deviceMetric('FLOW RATE', '${device['flowRate']} L/min'),
                const SizedBox(width: 24),
                _deviceMetric('LAST WATERED', '${device['lastWatered']}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _deviceMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 0.5, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }

  Widget _chartToggle(String text, int index) {
    final isActive = _chartView == index;
    return GestureDetector(
      onTap: () => setState(() => _chartView = index),
      child: Text(text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          decoration: isActive ? TextDecoration.underline : TextDecoration.none,
          decorationColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildEnergyChart() {
    final List<int> data = List<int>.from(_chartView == 0 ? _data['solarGen'] : _data['gridConsumption']);
    final maxVal = data.reduce((int a, int b) => a > b ? a : b).toDouble();
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: SizedBox(
        height: 160,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(data.length, (i) {
            final ratio = (data[i] as num) / maxVal;
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${data[i]}', style: TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 100 * ratio,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _chartView == 0
                            ? [AppColors.primary, AppColors.primary.withValues(alpha: 0.4)]
                            : [AppColors.tertiary, AppColors.tertiary.withValues(alpha: 0.4)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(days[i], style: TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCountCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.3)),
        ],
      ),
    );
  }
}
