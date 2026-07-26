import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class NavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.wifi_tethering_rounded),
              activeIcon: Icon(Icons.wifi_tethering_rounded, color: AppColors.primaryLight),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_remote_rounded),
              activeIcon: Icon(Icons.settings_remote_rounded, color: AppColors.primaryLight),
              label: 'Remote',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alt_route_rounded),
              activeIcon: Icon(Icons.alt_route_rounded, color: AppColors.primaryLight),
              label: 'Macros',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              activeIcon: Icon(Icons.tune_rounded, color: AppColors.primaryLight),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
