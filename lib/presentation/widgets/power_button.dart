import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PowerButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isConnected;

  const PowerButton({
    super.key,
    required this.onPressed,
    this.isConnected = true,
  });

  @override
  State<PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.reverse();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.forward();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.forward();
      },
      child: ScaleTransition(
        scale: _controller,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.powerGradient,
            boxShadow: [
              BoxShadow(
                color: widget.isConnected
                    ? AppColors.powerRedGlow
                    : Colors.transparent,
                blurRadius: _isPressed ? 18 : 12,
                spreadRadius: _isPressed ? 3 : 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.power_settings_new_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
