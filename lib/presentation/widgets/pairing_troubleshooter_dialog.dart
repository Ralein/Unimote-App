import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/discovery/wake_on_lan_service.dart';
import '../../domain/entities/device.dart';

class PairingTroubleshooterDialog extends StatefulWidget {
  final Device? device;
  final Function(Device updatedDevice) onUpdateDevice;
  final VoidCallback onRetryConnection;
  final Function(String pin)? onSubmitPin;

  const PairingTroubleshooterDialog({
    super.key,
    required this.device,
    required this.onUpdateDevice,
    required this.onRetryConnection,
    this.onSubmitPin,
  });

  @override
  State<PairingTroubleshooterDialog> createState() => _PairingTroubleshooterDialogState();
}

class _PairingTroubleshooterDialogState extends State<PairingTroubleshooterDialog> {
  final _pinController = TextEditingController();
  final _macController = TextEditingController();
  String? _wolStatus;

  @override
  void initState() {
    super.initState();
    if (widget.device?.macAddress != null) {
      _macController.text = widget.device!.macAddress!;
    }
  }

  void _triggerWakeOnLan() async {
    final mac = _macController.text.trim();
    if (mac.isEmpty) {
      setState(() => _wolStatus = 'Please enter MAC address (e.g. AA:BB:CC:DD:EE:FF)');
      return;
    }

    try {
      final success = await WakeOnLanService.sendWakeOnLan(mac);
      setState(() {
        _wolStatus = success ? 'Magic packet sent! Waiting for TV wake-up…' : 'Failed to send packet';
      });
    } catch (e) {
      setState(() => _wolStatus = 'Invalid MAC address format');
    }
  }

  void _toggleAlternatePort() {
    if (widget.device == null) return;
    final currentPort = widget.device!.port;
    int newPort = currentPort;

    if (widget.device!.brand == DeviceBrand.samsung) {
      newPort = currentPort == 8002 ? 8001 : 8002;
    } else if (widget.device!.brand == DeviceBrand.lg) {
      newPort = currentPort == 3001 ? 3000 : 3001;
    } else if (widget.device!.brand == DeviceBrand.vizio) {
      newPort = currentPort == 7345 ? 9000 : 7345;
    }

    final updated = widget.device!.copyWith(port: newPort);
    widget.onUpdateDevice(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched port from $currentPort to $newPort'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: const [
          Icon(Icons.build_circle_rounded, color: AppColors.primaryLight, size: 28),
          SizedBox(width: 10),
          Text(
            'Pairing Troubleshooter',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (device != null) ...[
              Text(
                'Target: ${device.name} (${device.ipAddress}:${device.port})',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
              ),
              const SizedBox(height: 12),
            ],

            const Text(
              'Diagnostic Checklist:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            _CheckItem(text: 'Phone & TV are on the exact same Wi-Fi subnet'),
            _CheckItem(text: 'Accept on-screen TV permission prompt when shown'),
            _CheckItem(text: 'Disable AP Isolation / Guest Mode in Wi-Fi router'),

            const SizedBox(height: 16),
            const Divider(color: AppColors.cardBorder),
            const SizedBox(height: 8),

            // PIN Entry Form for Vizio/LG/Android TV
            if (widget.onSubmitPin != null) ...[
              const Text(
                'Enter On-Screen TV PIN:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'e.g. 1234',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final pin = _pinController.text.trim();
                      if (pin.isNotEmpty && widget.onSubmitPin != null) {
                        widget.onSubmitPin!(pin);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Pair PIN'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Wake-on-LAN Tool
            const Text(
              'Wake TV via WoL (Power On):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _macController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'MAC (AA:BB:CC:DD:EE:FF)',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: _triggerWakeOnLan,
                  icon: const Icon(Icons.bolt_rounded, color: AppColors.primaryLight),
                  tooltip: 'Send WoL Packet',
                ),
              ],
            ),
            if (_wolStatus != null) ...[
              const SizedBox(height: 4),
              Text(
                _wolStatus!,
                style: const TextStyle(fontSize: 11, color: AppColors.primaryLight),
              ),
            ],

            const SizedBox(height: 16),
            // Port Switcher Action
            OutlinedButton.icon(
              onPressed: _toggleAlternatePort,
              icon: const Icon(Icons.alt_route_rounded, size: 18),
              label: const Text('Toggle WSS / WS Port (e.g. 8002 ↔ 8001)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onRetryConnection();
          },
          child: const Text('Retry Connection'),
        ),
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;

  const _CheckItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.primaryLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
