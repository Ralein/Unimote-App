import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../data/adapters/bluetooth_adapter.dart';
import '../../data/adapters/ir_adapter.dart';
import '../../domain/entities/adapter_state.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/remote_key.dart';
import '../providers/adapter_provider.dart';
import '../widgets/app_launcher_grid.dart';
import '../widgets/dpad.dart';
import '../widgets/numeric_pad.dart';
import '../widgets/pairing_troubleshooter_dialog.dart';
import '../widgets/power_button.dart';
import '../widgets/trackpad_widget.dart';
import '../widgets/volume_slider.dart';

enum RemoteControlMode {
  dpad,
  trackpad,
  apps,
}

enum ConnectionMode {
  wifi,
  bluetooth,
  ir,
}

class RemoteScreen extends ConsumerStatefulWidget {
  const RemoteScreen({super.key});

  @override
  ConsumerState<RemoteScreen> createState() => _RemoteScreenState();
}

class _RemoteScreenState extends ConsumerState<RemoteScreen> {
  bool _showNumericPad = false;
  RemoteControlMode _controlMode = RemoteControlMode.dpad;
  ConnectionMode _connectionMode = ConnectionMode.wifi;
  late final IrAdapter _irAdapter = IrAdapter();
  late final BluetoothAdapter _btAdapter = BluetoothAdapter();
  bool _hasIrHardware = false;
  bool _hasBluetoothHardware = true;

  @override
  void initState() {
    super.initState();
    _checkHardware();
  }

  void _checkHardware() async {
    final hasIr = await _irAdapter.hasIrEmitter();
    final hasBt = await BluetoothAdapter.isBluetoothAvailable();
    if (mounted) {
      setState(() {
        _hasIrHardware = hasIr;
        _hasBluetoothHardware = hasBt;
      });
    }
  }

  void _handleKey(RemoteKey key) {
    if (_connectionMode == ConnectionMode.ir) {
      _irAdapter.sendKey(key);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent IR Signal: ${key.displayName}'),
          duration: const Duration(milliseconds: 600),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    } else if (_connectionMode == ConnectionMode.bluetooth) {
      _btAdapter.sendKey(key);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent Bluetooth Key: ${key.displayName}'),
          duration: const Duration(milliseconds: 600),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final adapter = ref.read(activeAdapterProvider);
    if (adapter != null) {
      adapter.sendKey(key);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent Wi-Fi Key: ${key.displayName}'),
          duration: const Duration(milliseconds: 600),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No TV connected. Use Discovery or switch to Bluetooth/IR Mode.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
                if (_connectionMode == ConnectionMode.bluetooth) {
                  _btAdapter.sendText(text);
                } else {
                  ref.read(activeAdapterProvider)?.sendText(text);
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _openTroubleshooter(AdapterState adapterState) {
    showDialog(
      context: context,
      builder: (context) => PairingTroubleshooterDialog(
        device: adapterState.connectedDevice,
        onUpdateDevice: (updatedDevice) {
          ref.read(adapterNotifierProvider.notifier).connectToDevice(updatedDevice);
        },
        onRetryConnection: () {
          if (adapterState.connectedDevice != null) {
            ref.read(adapterNotifierProvider.notifier).connectToDevice(adapterState.connectedDevice!);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adapterState = ref.watch(adapterNotifierProvider);
    final currentDevice = adapterState.connectedDevice;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              _connectionMode == ConnectionMode.ir
                  ? 'IR Blaster Remote'
                  : (_connectionMode == ConnectionMode.bluetooth
                      ? 'Bluetooth HID Remote'
                      : (currentDevice?.name ?? 'Unimote Control')),
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
                    color: _connectionMode == ConnectionMode.ir
                        ? (_hasIrHardware ? AppColors.statusGreen : AppColors.powerRed)
                        : (_connectionMode == ConnectionMode.bluetooth
                            ? (_hasBluetoothHardware ? AppColors.statusGreen : AppColors.powerRed)
                            : (adapterState.isConnected
                                ? AppColors.statusGreen
                                : (adapterState.isPairing
                                    ? AppColors.warningAmber
                                    : AppColors.powerRed))),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _connectionMode == ConnectionMode.ir
                      ? (_hasIrHardware ? 'IR EMITTER READY' : 'NO IR HARDWARE')
                      : (_connectionMode == ConnectionMode.bluetooth
                          ? (_hasBluetoothHardware ? 'BLUETOOTH HID READY' : 'NO BLUETOOTH')
                          : adapterState.status.name.toUpperCase()),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _connectionMode == ConnectionMode.ir
                        ? (_hasIrHardware ? AppColors.statusGreen : AppColors.powerRed)
                        : (_connectionMode == ConnectionMode.bluetooth
                            ? (_hasBluetoothHardware ? AppColors.statusGreen : AppColors.powerRed)
                            : (adapterState.isConnected
                                ? AppColors.statusGreen
                                : (adapterState.isPairing
                                    ? AppColors.warningAmber
                                    : AppColors.powerRed))),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.build_rounded),
            tooltip: 'Pairing Assistant',
            onPressed: () => _openTroubleshooter(adapterState),
          ),
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
              // Connection Mode Switcher: Wi-Fi vs Bluetooth vs IR Blaster
              SegmentedButton<ConnectionMode>(
                segments: const [
                  ButtonSegment(
                    value: ConnectionMode.wifi,
                    icon: Icon(Icons.wifi_rounded),
                    label: Text('Wi-Fi'),
                  ),
                  ButtonSegment(
                    value: ConnectionMode.bluetooth,
                    icon: Icon(Icons.bluetooth_rounded),
                    label: Text('Bluetooth'),
                  ),
                  ButtonSegment(
                    value: ConnectionMode.ir,
                    icon: Icon(Icons.sensors_rounded),
                    label: Text('IR'),
                  ),
                ],
                selected: {_connectionMode},
                onSelectionChanged: (Set<ConnectionMode> selection) {
                  setState(() {
                    _connectionMode = selection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return AppColors.surfaceElevated;
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // Comprehensive Connection Status Banners for Wi-Fi Mode
              if (_connectionMode == ConnectionMode.wifi) ...[
                if (adapterState.isPairing && currentDevice != null) ...[
                  // PAIRING STATE BANNER (Yellow Alert)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warningAmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.warningAmber, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(AppColors.warningAmber),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Pairing with ${currentDevice.name} (${currentDevice.ipAddress})...',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '👉 Look at your TV screen now! Use your physical TV remote to select "ALLOW" or "ACCEPT".',
                          style: TextStyle(fontSize: 12, color: AppColors.warningAmber, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _openTroubleshooter(adapterState),
                              icon: const Icon(Icons.build_rounded, size: 14),
                              label: const Text('Pairing Assistant'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warningAmber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else if (adapterState.isError) ...[
                  // ERROR STATE BANNER (Red Alert)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.powerRedGlow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.powerRed, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.powerRed, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                adapterState.errorMessage ?? 'Failed to connect to TV',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => _openTroubleshooter(adapterState),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.cardBorder),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              child: const Text('Diagnostic 🛠️', style: TextStyle(fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (currentDevice != null) {
                                  ref.read(adapterNotifierProvider.notifier).connectToDevice(currentDevice);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              child: const Text('Retry 🔄', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else if (!adapterState.isConnected && !adapterState.isConnecting) ...[
                  // DISCONNECTED BANNER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tv_off_rounded, color: AppColors.textMuted, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'No Wi-Fi TV Connected. Tap Discovery or switch to Bluetooth/IR mode.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _openTroubleshooter(adapterState),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Connect'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],

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
                    isConnected: _connectionMode != ConnectionMode.wifi ? true : adapterState.isConnected,
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

              const SizedBox(height: 20),

              // Control Mode Switcher Segmented Control
              SegmentedButton<RemoteControlMode>(
                segments: const [
                  ButtonSegment(
                    value: RemoteControlMode.dpad,
                    icon: Icon(Icons.grid_view_rounded),
                    label: Text('DPad'),
                  ),
                  ButtonSegment(
                    value: RemoteControlMode.trackpad,
                    icon: Icon(Icons.touch_app_rounded),
                    label: Text('Trackpad'),
                  ),
                  ButtonSegment(
                    value: RemoteControlMode.apps,
                    icon: Icon(Icons.apps_rounded),
                    label: Text('Apps'),
                  ),
                ],
                selected: {_controlMode},
                onSelectionChanged: (Set<RemoteControlMode> selection) {
                  setState(() {
                    _controlMode = selection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return AppColors.surfaceElevated;
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // Dynamic Control View (DPAD / Trackpad / App Launcher)
              if (_controlMode == RemoteControlMode.dpad) ...[
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

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DPadWidget(onKey: _handleKey),
                    const SizedBox(width: 12),
                    VolumeRockerWidget(onKey: _handleKey),
                  ],
                ),
              ] else if (_controlMode == RemoteControlMode.trackpad) ...[
                TrackpadWidget(onKey: _handleKey),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _RoundIconButton(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onPressed: () => _handleKey(RemoteKey.home),
                    ),
                    _RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      label: 'Back',
                      onPressed: () => _handleKey(RemoteKey.back),
                    ),
                  ],
                ),
              ] else if (_controlMode == RemoteControlMode.apps) ...[
                AppLauncherGridWidget(
                  brand: currentDevice?.brand ?? DeviceBrand.samsung,
                  onLaunchApp: (appId) {
                    if (_connectionMode == ConnectionMode.wifi) {
                      ref.read(activeAdapterProvider)?.launchApp(appId);
                    }
                  },
                ),
              ],

              const SizedBox(height: 20),

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
