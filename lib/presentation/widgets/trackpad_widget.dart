import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/remote_key.dart';

class TrackpadWidget extends StatefulWidget {
  final Function(RemoteKey key) onKey;

  const TrackpadWidget({
    super.key,
    required this.onKey,
  });

  @override
  State<TrackpadWidget> createState() => _TrackpadWidgetState();
}

class _TrackpadWidgetState extends State<TrackpadWidget> {
  Offset _dragStart = Offset.zero;
  bool _isHovering = false;

  void _handleDragStart(DragStartDetails details) {
    _dragStart = details.localPosition;
    setState(() => _isHovering = true);
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() => _isHovering = false);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final diff = details.localPosition - _dragStart;
    const threshold = 40.0;

    if (diff.dx.abs() > threshold || diff.dy.abs() > threshold) {
      HapticFeedback.lightImpact();
      if (diff.dx.abs() > diff.dy.abs()) {
        if (diff.dx > 0) {
          widget.onKey(RemoteKey.dpadRight);
        } else {
          widget.onKey(RemoteKey.dpadLeft);
        }
      } else {
        if (diff.dy > 0) {
          widget.onKey(RemoteKey.dpadDown);
        } else {
          widget.onKey(RemoteKey.dpadUp);
        }
      }
      _dragStart = details.localPosition; // Reset baseline for continuous drag
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDragStart,
      onPanUpdate: _handleDragUpdate,
      onPanEnd: _handleDragEnd,
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onKey(RemoteKey.select);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: _isHovering
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovering ? AppColors.primaryLight : AppColors.cardBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: const [
            Icon(
              Icons.touch_app_rounded,
              size: 44,
              color: AppColors.textMuted,
            ),
            Positioned(
              bottom: 12,
              child: Text(
                'Swipe for DPAD • Tap for Select',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
