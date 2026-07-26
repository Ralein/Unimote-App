import 'package:flutter_test/flutter_test.dart';
import 'package:unimote/data/adapters/app_launcher_service.dart';
import 'package:unimote/domain/entities/device.dart';

void main() {
  group('AppLauncherService Unit Tests', () {
    test('Returns correct brand App ID for popular shortcuts', () {
      final netflix = AppLauncherService.popularShortcuts.firstWhere((s) => s.id == 'netflix');

      expect(netflix.getAppIdForBrand(DeviceBrand.samsung), equals('3201900001938'));
      expect(netflix.getAppIdForBrand(DeviceBrand.lg), equals('netflix'));
      expect(netflix.getAppIdForBrand(DeviceBrand.roku), equals('12'));
      expect(netflix.getAppIdForBrand(DeviceBrand.androidTv), equals('com.netflix.ninja'));
    });
  });
}
