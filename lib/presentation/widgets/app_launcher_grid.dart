import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/adapters/app_launcher_service.dart';
import '../../domain/entities/device.dart';

class AppLauncherGridWidget extends StatelessWidget {
  final DeviceBrand brand;
  final Function(String appId) onLaunchApp;

  const AppLauncherGridWidget({
    super.key,
    required this.brand,
    required this.onLaunchApp,
  });

  @override
  Widget build(BuildContext context) {
    final shortcuts = AppLauncherService.popularShortcuts;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Streaming App Shortcuts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shortcuts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final shortcut = shortcuts[index];
              final appId = shortcut.getAppIdForBrand(brand);

              return _AppTile(
                shortcut: shortcut,
                appId: appId,
                onTap: () {
                  if (appId != null) {
                    onLaunchApp(appId);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AppTile extends StatefulWidget {
  final AppShortcut shortcut;
  final String? appId;
  final VoidCallback onTap;

  const _AppTile({
    required this.shortcut,
    required this.appId,
    required this.onTap,
  });

  @override
  State<_AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<_AppTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSupported = widget.appId != null;

    return GestureDetector(
      onTapDown: (_) {
        if (isSupported) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (isSupported) {
          setState(() => _isPressed = false);
          widget.onTap();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.primary.withValues(alpha: 0.3)
              : (isSupported ? AppColors.surfaceElevated : AppColors.surface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isPressed
                ? AppColors.primaryLight
                : (isSupported ? AppColors.cardBorder : Colors.transparent),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconData(widget.shortcut.iconAssetOrName),
                size: 18,
                color: isSupported ? AppColors.primaryLight : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                widget.shortcut.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSupported ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'movie_filter':
        return Icons.movie_filter_rounded;
      case 'play_circle_fill':
        return Icons.play_circle_fill_rounded;
      case 'video_library':
        return Icons.video_library_rounded;
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      case 'tv':
        return Icons.tv_rounded;
      case 'music_note':
        return Icons.music_note_rounded;
      default:
        return Icons.apps_rounded;
    }
  }
}
