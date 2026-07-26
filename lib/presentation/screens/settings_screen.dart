import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'General',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: true,
                  onChanged: (val) {},
                  title: const Text('Dark Mode Default'),
                  subtitle: const Text('Optimal for dark home theater viewing'),
                  activeColor: AppColors.primary,
                ),
                const Divider(height: 1, color: AppColors.cardBorder),
                SwitchListTile(
                  value: true,
                  onChanged: (val) {},
                  title: const Text('Haptic Feedback'),
                  subtitle: const Text('Vibrate on button taps'),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Hardware & Permissions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.wifi, color: AppColors.textPrimary),
                  title: Text('Local Network Permission'),
                  subtitle: Text('Granted (iOS 14+ / Android 13+)'),
                  trailing: Icon(Icons.check_circle_rounded, color: AppColors.statusGreen),
                ),
                Divider(height: 1, color: AppColors.cardBorder),
                ListTile(
                  leading: Icon(Icons.sensors_rounded, color: AppColors.textPrimary),
                  title: Text('IR Blaster Emitter Check'),
                  subtitle: Text('Hardware scan: Not detected (WiFi Mode)'),
                  trailing: Icon(Icons.info_outline_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'About Unimote',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: const [
                ListTile(
                  title: Text('Version'),
                  trailing: Text('1.0.0 (Phase 1 Build)', style: TextStyle(color: AppColors.textSecondary)),
                ),
                Divider(height: 1, color: AppColors.cardBorder),
                ListTile(
                  title: Text('Architecture'),
                  trailing: Text('Clean Architecture + Riverpod', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
