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
  Offset? _tapRipplePosition;

  void _handleDragStart(DragStartDetails details) {
    _dragStart = details.localPosition;
    setState(() {
      _isHovering = true;
      _tapRipplePosition = details.localPosition;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isHovering = false;
      _tapRipplePosition = null;
    });

    // Fling velocity check (TV Bro inspiration)
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.dx.abs() > 1000 || velocity.dy.abs() > 1000) {
      HapticFeedback.heavyImpact();
      if (velocity.dx.abs() > velocity.dy.abs()) {
        widget.onKey(velocity.dx > 0 ? RemoteKey.dpadRight : RemoteKey.dpadLeft);
      } else {
        widget.onKey(velocity.dy > 0 ? RemoteKey.dpadDown : RemoteKey.dpadUp);
      }
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final diff = details.localPosition - _dragStart;
    const threshold = 35.0;

    if (diff.dx.abs() > threshold || diff.dy.abs() > threshold) {
      HapticFeedback.lightImpact();
      if (diff.dx.abs() > diff.dy.abs()) {
        widget.onKey(diff.dx > 0 ? RemoteKey.dpadRight : RemoteKey.dpadLeft);
      } else {
        widget.onKey(diff.dy > 0 ? RemoteKey.dpadDown : RemoteKey.dpadUp);
      }
      _dragStart = details.localPosition;
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
      onDoubleTap: () {
        HapticFeedback.mediumImpact();
        widget.onKey(RemoteKey.back);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: _isHovering
              ? AppColors.primary.withValues(alpha: 0.2)
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
          children: [
            if (_tapRipplePosition != null)
              Positioned(
                left: _tapRipplePosition!.dx - 20,
                top: _tapRipplePosition!.dy - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 48,
                  color: AppColors.primaryLight,
                ),
                SizedBox(height: 8),
                Text(
                  'Trackpad Virtual Pointer',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Positioned(
              bottom: 12,
              child: Text(
                'Swipe to move • Tap Select • Double-Tap Back',
                style: TextStyle(
                  fontSize: 11,
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
