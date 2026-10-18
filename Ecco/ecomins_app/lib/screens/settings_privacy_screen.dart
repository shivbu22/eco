import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'terms_conditions_screen.dart';
import 'privacy_policy_screen.dart';

import '../services/database_service.dart';

class SettingsPrivacyScreen extends StatefulWidget {
  const SettingsPrivacyScreen({super.key});

  @override
  State<SettingsPrivacyScreen> createState() => _SettingsPrivacyScreenState();
}

class _SettingsPrivacyScreenState extends State<SettingsPrivacyScreen> {
  final DatabaseService _db = DatabaseService();
  late Map<String, dynamic> _settings;

  @override
  void initState() {
    super.initState();
    _settings = _db.getUserSettings();
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('SETTINGS & PRIVACY',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 1.5, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 4),
            const Text('Settings',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 24),

            // ── Profile Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
                    ),
                    child: const Center(child: Text('🧑', style: TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_settings['name'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_settings['tier'],
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined, color: AppColors.primary, size: 22),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Account Section ──
            _sectionHeader('ACCOUNT'),
            _settingsTile(Icons.email_outlined, 'Email', _settings['email']),
            _settingsTile(Icons.phone_outlined, 'Phone', _settings['phone'],
                trailing: _settings['phoneVerified']
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.verified, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('Verified', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ])
                    : null),
            _settingsTile(Icons.language, 'Language', 'English'),
            const SizedBox(height: 24),

            // ── Security Section ──
            _sectionHeader('SECURITY'),
            _settingsToggle(Icons.fingerprint, 'Two-Factor Auth', _settings['twoFactorEnabled'],
                (v) => setState(() => _settings['twoFactorEnabled'] = v)),
            _settingsTile(Icons.lock_outline, 'Change Password', '••••••••'),
            _settingsToggle(Icons.location_on_outlined, 'Location Access', _settings['locationAccess'],
                (v) => setState(() => _settings['locationAccess'] = v)),
            _settingsToggle(Icons.visibility_outlined, 'Profile Visibility', _settings['profileVisibility'],
                (v) => setState(() => _settings['profileVisibility'] = v)),
            const SizedBox(height: 24),

            // ── Notifications Section ──
            _sectionHeader('NOTIFICATIONS'),
            _settingsToggle(Icons.flash_on, 'Flash Offers', _settings['flashOffers'],
                (v) => setState(() => _settings['flashOffers'] = v)),
            _settingsToggle(Icons.notifications_outlined, 'Service Updates', _settings['serviceUpdates'],
                (v) => setState(() => _settings['serviceUpdates'] = v)),
            const SizedBox(height: 24),

            // ── Eco Section ──
            _sectionHeader('ECO & DATA'),
            _settingsTile(Icons.eco_rounded, 'Carbon Footprint Report', 'Download PDF'),
            _settingsTile(Icons.download_outlined, 'Export My Data', 'GDPR Compliance'),
            _settingsTile(Icons.delete_forever_outlined, 'Delete Account', 'Permanent Action',
                isDestructive: true),
            const SizedBox(height: 32),

            // ── Version ──
            Center(
              child: Column(
                children: [
                  Text('OZOMIN',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                          letterSpacing: 2, color: AppColors.primary, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),
                  Text('v${_settings['version']}',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen()));
                      }, child: Text('Terms',
                          style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant))),
                      Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                      TextButton(onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                      }, child: Text('Privacy',
                          style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant))),
                      Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                      TextButton(onPressed: () {}, child: Text('Licenses',
                          style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Logout ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('LOG OUT', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.tertiary,
                  side: BorderSide(color: AppColors.tertiary.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
              letterSpacing: 1.2, color: AppColors.primary)),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle,
      {Widget? trailing, bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive
              ? AppColors.tertiary.withValues(alpha: 0.2)
              : AppColors.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: (isDestructive ? AppColors.tertiary : AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18,
              color: isDestructive ? AppColors.tertiary : AppColors.primary),
        ),
        title: Text(title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: isDestructive ? AppColors.tertiary : Colors.white)),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
        trailing: trailing ?? Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 20),
        onTap: () {},
      ),
    );
  }

  Widget _settingsToggle(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          inactiveTrackColor: AppColors.surfaceContainerHigh,
        ),
      ),
    );
  }
}
