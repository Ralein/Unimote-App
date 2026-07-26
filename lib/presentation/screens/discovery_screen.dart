import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/device.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  bool _isScanning = false;

  final List<Device> _mockDiscoveredDevices = const [
    Device(
      id: 'samsung-tizen-55',
      name: 'Living Room Samsung TV (Q70T)',
      brand: DeviceBrand.samsung,
      ipAddress: '192.168.1.105',
      port: 8002,
    ),
    Device(
      id: 'lg-webos-65',
      name: 'Bedroom LG OLED TV',
      brand: DeviceBrand.lg,
      ipAddress: '192.168.1.112',
      port: 3001,
    ),
    Device(
      id: 'roku-ultra-01',
      name: 'Roku Ultra Streaming Box',
      brand: DeviceBrand.roku,
      ipAddress: '192.168.1.120',
      port: 8060,
    ),
  ];

  void _toggleScan() {
    setState(() {
      _isScanning = !_isScanning;
    });
  }

  void _showManualAddBottomSheet() {
    final ipController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
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
              'Add Device by IP Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use this fallback for Fire TV or TVs that do not answer SSDP/mDNS broadcasts.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ipController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. 192.168.1.150',
                hintStyle: const TextStyle(color: AppColors.textMuted),
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Add & Connect'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // Scan Status Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    if (_isScanning)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(AppColors.primaryLight),
                        ),
                      )
                    else
                      const Icon(Icons.radar_rounded, color: AppColors.primaryLight, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isScanning ? 'Scanning local network…' : 'Network Scanner Idle',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'SSDP (multicast) & mDNS / Bonjour',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _toggleScan,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: Text(_isScanning ? 'Stop' : 'Scan'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Discovered Devices',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  itemCount: _mockDiscoveredDevices.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final device = _mockDiscoveredDevices[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.surfaceElevated,
                          child: Icon(
                            _getBrandIcon(device.brand),
                            color: AppColors.primaryLight,
                          ),
                        ),
                        title: Text(
                          device.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${device.brand.name.toUpperCase()} • ${device.ipAddress}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selected device: ${device.name}'),
                              duration: const Duration(seconds: 1),
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
