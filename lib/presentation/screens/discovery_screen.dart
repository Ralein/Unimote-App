import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/device.dart';
import '../providers/discovery_provider.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Trigger initial scan on screen entry
    Future.microtask(() {
      ref.read(discoveryProvider.notifier).startScan();
    });
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _showManualAddBottomSheet() {
    final ipController = TextEditingController();
    DeviceBrand selectedBrand = DeviceBrand.samsung;
    String? localError;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add TV by IP Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Required fallback for Fire TV or devices that do not broadcast SSDP/mDNS.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DeviceBrand>(
                value: selectedBrand,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Target TV Brand',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: DeviceBrand.samsung, child: Text('Samsung Tizen')),
                  DropdownMenuItem(value: DeviceBrand.lg, child: Text('LG webOS')),
                  DropdownMenuItem(value: DeviceBrand.roku, child: Text('Roku ECP')),
                  DropdownMenuItem(value: DeviceBrand.fireTv, child: Text('Fire TV (ADB)')),
                  DropdownMenuItem(value: DeviceBrand.androidTv, child: Text('Android TV / Google Cast')),
                  DropdownMenuItem(value: DeviceBrand.sony, child: Text('Sony Bravia')),
                  DropdownMenuItem(value: DeviceBrand.vizio, child: Text('Vizio SmartCast')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedBrand = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ipController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'IP Address',
                  hintText: 'e.g. 192.168.1.150',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  errorText: localError,
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final ip = ipController.text.trim();
                    try {
                      await ref
                          .read(discoveryProvider.notifier)
                          .addManualDevice(ip, brand: selectedBrand);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (err) {
                      setModalState(() {
                        localError = 'Invalid IP address format';
                      });
                    }
                  },
                  child: const Text('Add & Connect'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(discoveryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Discovery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link_rounded),
            tooltip: 'Add by IP',
            onPressed: _showManualAddBottomSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scanning Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    if (discoveryState.isScanning)
                      RotationTransition(
                        turns: _radarController,
                        child: const Icon(
                          Icons.radar_rounded,
                          color: AppColors.primaryLight,
                          size: 30,
                        ),
                      )
                    else
                      const Icon(
                        Icons.radar_rounded,
                        color: AppColors.textMuted,
                        size: 30,
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            discoveryState.isScanning
                                ? 'Scanning local network…'
                                : 'Scanner Idle',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'SSDP (239.255.255.250:1900) & mDNS',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final notifier = ref.read(discoveryProvider.notifier);
                        if (discoveryState.isScanning) {
                          notifier.stopScan();
                        } else {
                          notifier.startScan();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      child: Text(discoveryState.isScanning ? 'Stop' : 'Scan'),
                    ),
                  ],
                ),
              ),

              if (discoveryState.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.powerRedGlow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.powerRed, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          discoveryState.errorMessage!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Discovered Devices',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${discoveryState.devices.length} Found',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: discoveryState.devices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.tv_off_rounded,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              discoveryState.isScanning
                                  ? 'Searching for TVs on Wi-Fi…'
                                  : 'No devices found yet',
                              style: const TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap Scan or Add TV by IP address above.',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: discoveryState.devices.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final device = discoveryState.devices[index];
                          final isSelected =
                              discoveryState.selectedDevice?.id == device.id;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : AppColors.cardBorder,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.surfaceElevated,
                                child: Icon(
                                  _getBrandIcon(device.brand),
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : AppColors.textPrimary,
                                ),
                              ),
                              title: Text(
                                device.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                '${device.brand.name.toUpperCase()} • ${device.ipAddress}:${device.port}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primaryLight,
                                    )
                                  : const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.textMuted,
                                    ),
                              onTap: () {
                                ref
                                    .read(discoveryProvider.notifier)
                                    .selectDevice(device);
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Connected to ${device.name}'),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBrandIcon(DeviceBrand brand) {
    switch (brand) {
      case DeviceBrand.samsung:
      case DeviceBrand.lg:
      case DeviceBrand.vizio:
      case DeviceBrand.sony:
        return Icons.tv_rounded;
      case DeviceBrand.roku:
      case DeviceBrand.fireTv:
      case DeviceBrand.androidTv:
        return Icons.developer_board_rounded;
      default:
        return Icons.devices_other_rounded;
    }
  }
}
