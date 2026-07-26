import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/remote_key.dart';

class DPadWidget extends StatelessWidget {
  final Function(RemoteKey key) onKey;

  const DPadWidget({
    super.key,
    required this.onKey,
  });

  @override
  Widget build(BuildContext context) {
    const double outerSize = 220;
    const double buttonSize = 54;

    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.dpadGradient,
        border: Border.all(color: AppColors.cardBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // DPad Up
          Positioned(
            top: 10,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_up_rounded,
              size: buttonSize,
              onPressed: () => onKey(RemoteKey.dpadUp),
            ),
          ),

          // DPad Down
          Positioned(
            bottom: 10,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_down_rounded,
              size: buttonSize,
              onPressed: () => onKey(RemoteKey.dpadDown),
            ),
          ),

          // DPad Left
          Positioned(
            left: 10,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_left_rounded,
              size: buttonSize,
              onPressed: () => onKey(RemoteKey.dpadLeft),
            ),
          ),

          // DPad Right
          Positioned(
            right: 10,
            child: _DPadButton(
              icon: Icons.keyboard_arrow_right_rounded,
              size: buttonSize,
              onPressed: () => onKey(RemoteKey.dpadRight),
            ),
          ),

          // Center Select Button
          _CenterSelectButton(
            size: 64,
            onPressed: () => onKey(RemoteKey.select),
          ),
        ],
      ),
    );
  }
}

class _DPadButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  const _DPadButton({
    required this.icon,
    required this.size,
    required this.onPressed,
  });

  @override
  State<_DPadButton> createState() => _DPadButtonState();
}

class _DPadButtonState extends State<_DPadButton> {
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
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon,
          size: 32,
          color: _isPressed ? AppColors.primaryLight : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _CenterSelectButton extends StatefulWidget {
  final double size;
  final VoidCallback onPressed;

  const _CenterSelectButton({
    required this.size,
    required this.onPressed,
  });

  @override
  State<_CenterSelectButton> createState() => _CenterSelectButtonState();
}

class _CenterSelectButtonState extends State<_CenterSelectButton> {
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
        duration: const Duration(milliseconds: 120),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _isPressed
              ? AppColors.primaryGradient
              : const LinearGradient(
                  colors: [AppColors.surfaceElevated, AppColors.surface],
                ),
          border: Border.all(
            color: _isPressed ? AppColors.primaryLight : AppColors.cardBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.black26,
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'OK',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.5,
              color: _isPressed ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
