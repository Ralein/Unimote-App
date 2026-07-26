import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/remote_key.dart';

class NumericPadWidget extends StatelessWidget {
  final Function(RemoteKey key) onKey;

  const NumericPadWidget({
    super.key,
    required this.onKey,
  });

  static const List<RemoteKey> _keys = [
    RemoteKey.num1,
    RemoteKey.num2,
    RemoteKey.num3,
    RemoteKey.num4,
    RemoteKey.num5,
    RemoteKey.num6,
    RemoteKey.num7,
    RemoteKey.num8,
    RemoteKey.num9,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              ..._keys.map((k) => _NumButton(remoteKey: k, onKey: onKey)),
              const SizedBox.shrink(),
              _NumButton(remoteKey: RemoteKey.num0, onKey: onKey),
              const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumButton extends StatefulWidget {
  final RemoteKey remoteKey;
  final Function(RemoteKey key) onKey;

  const _NumButton({
    required this.remoteKey,
    required this.onKey,
  });

  @override
  State<_NumButton> createState() => _NumButtonState();
}

class _NumButtonState extends State<_NumButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onKey(widget.remoteKey);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isPressed ? AppColors.primaryLight : AppColors.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            widget.remoteKey.displayName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isPressed ? AppColors.primaryLight : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
