import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/remote_key.dart';
import '../providers/adapter_provider.dart';
import '../widgets/dpad.dart';
import '../widgets/numeric_pad.dart';
import '../widgets/power_button.dart';
import '../widgets/volume_slider.dart';

class RemoteScreen extends ConsumerStatefulWidget {
  const RemoteScreen({super.key});

  @override
  ConsumerState<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends ConsumerState<RemoteScreen> {
  bool _showNumericPad = false;

  void _handleKey(RemoteKey key) {
    final adapter = ref.read(activeAdapterProvider);
    adapter.sendKey(key);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent key: ${key.displayName}'),
        duration: const Duration(milliseconds: 600),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showTextInputDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Send Text to TV', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter search text or URL...',
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                ref.read(activeAdapterProvider).sendText(text);
              }
              Navigator.pop(context);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adapterStateAsync = ref.watch(adapterStateProvider);
    final adapterState = adapterStateAsync.value ?? const AdapterState.disconnected();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              adapterState.connectedDevice?.name ?? 'Unimote Control',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: adapterState.isConnected
                        ? AppColors.statusGreen
                        : AppColors.warningAmber,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  adapterState.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: adapterState.isConnected
                        ? AppColors.statusGreen
                        : AppColors.warningAmber,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_rounded),
            tooltip: 'Send Text',
            onPressed: _showTextInputDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Top Action Row: Power Button & Quick Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickActionButton(
                    icon: Icons.input_rounded,
                    label: 'Input',
                    onPressed: () => _handleKey(RemoteKey.inputSource),
                  ),
                  PowerButton(
                    isConnected: adapterState.isConnected,
                    onPressed: () => _handleKey(RemoteKey.power),
                  ),
                  _QuickActionButton(
                    icon: Icons.pin_outlined,
                    label: _showNumericPad ? 'Hide 123' : 'Keypad',
                    onPressed: () {
                      setState(() {
                        _showNumericPad = !_showNumericPad;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Navigation Key Controls (Home, Back, Play/Pause)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RoundIconButton(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    onPressed: () => _handleKey(RemoteKey.home),
                  ),
                  _RoundIconButton(
                    icon: Icons.play_arrow_rounded,
                    label: 'Play/Pause',
                    onPressed: () => _handleKey(RemoteKey.playPause),
                  ),
                  _RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    label: 'Back',
                    onPressed: () => _handleKey(RemoteKey.back),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // DPAD & Volume Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DPadWidget(onKey: _handleKey),
                  const SizedBox(width: 12),
                  VolumeRockerWidget(onKey: _handleKey),
                ],
              ),

              const SizedBox(height: 24),

              // Expandable Numeric Keypad
              if (_showNumericPad) ...[
                NumericPadWidget(onKey: _handleKey),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon, color: AppColors.textPrimary),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            minimumSize: const Size(48, 48),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _RoundIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
