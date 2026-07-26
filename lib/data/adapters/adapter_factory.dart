import '../../domain/entities/device.dart';
import '../../domain/repositories/remote_adapter.dart';
import '../storage/token_repository.dart';
import 'androidtv_adapter.dart';
import 'firetv_adapter.dart';
import 'ir_adapter.dart';
import 'lg_adapter.dart';
import 'mock_adapter.dart';
import 'roku_adapter.dart';
import 'samsung_adapter.dart';
import 'sony_adapter.dart';
import 'vizio_adapter.dart';

class AdapterFactory {
  static RemoteAdapter createAdapter(
    Device device, {
    TokenRepository? tokenRepository,
  }) {
    switch (device.brand) {
      case DeviceBrand.samsung:
        return SamsungAdapter(tokenRepository: tokenRepository);
      case DeviceBrand.lg:
        return LgAdapter(tokenRepository: tokenRepository);
      case DeviceBrand.roku:
        return RokuAdapter();
      case DeviceBrand.fireTv:
        return FireTvAdapter();
      case DeviceBrand.androidTv:
        return AndroidTvAdapter();
      case DeviceBrand.vizio:
        return VizioAdapter();
      case DeviceBrand.sony:
        return SonyAdapter();
      case DeviceBrand.genericIr:
        return IrAdapter();
      case DeviceBrand.mock:
        return MockAdapter();
    }
  }
}
