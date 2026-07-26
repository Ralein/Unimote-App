import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/remote_key.dart';

class VolumeRockerWidget extends StatelessWidget {
  final Function(RemoteKey key) onKey;

  const VolumeRockerWidget({
    super.key,
    required this.onKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: _RockerButton(
              icon: Icons.add_rounded,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              onPressed: () => onKey(RemoteKey.volumeUp),
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          _RockerButton(
            icon: Icons.volume_off_rounded,
            borderRadius: BorderRadius.zero,
            height: 44,
            iconSize: 20,
            onPressed: () => onKey(RemoteKey.mute),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          Expanded(
            child: _RockerButton(
              icon: Icons.remove_rounded,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              onPressed: () => onKey(RemoteKey.volumeDown),
            ),
          ),
        ],
      ),
    );
  }
}

class _RockerButton extends StatefulWidget {
  final IconData icon;
  final BorderRadius borderRadius;
  final double? height;
  final double iconSize;
  final VoidCallback onPressed;

  const _RockerButton({
    required this.icon,
    required this.borderRadius,
    this.height,
    this.iconSize = 24,
    required this.onPressed,
  });

  @override
  State<_RockerButton> createState() => _RockerButtonState();
}

class _RockerButtonState extends State<_RockerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: widget.height,
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.primary.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: widget.borderRadius,
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: _isPressed ? AppColors.primaryLight : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
