import '../../domain/entities/device.dart';

class AppShortcut {
  final String id;
  final String displayName;
  final String iconAssetOrName;
  final Map<DeviceBrand, String> brandAppIds;

  const AppShortcut({
    required this.id,
    required this.displayName,
    required this.iconAssetOrName,
    required this.brandAppIds,
  });

  String? getAppIdForBrand(DeviceBrand brand) {
    return brandAppIds[brand];
  }
}

class AppLauncherService {
  static const List<AppShortcut> popularShortcuts = [
    AppShortcut(
      id: 'netflix',
      displayName: 'Netflix',
      iconAssetOrName: 'movie_filter',
      brandAppIds: {
        DeviceBrand.samsung: '3201900001938',
        DeviceBrand.lg: 'netflix',
        DeviceBrand.roku: '12',
        DeviceBrand.androidTv: 'com.netflix.ninja',
        DeviceBrand.fireTv: 'com.netflix.ninja',
      },
    ),
    AppShortcut(
      id: 'youtube',
      displayName: 'YouTube',
      iconAssetOrName: 'play_circle_fill',
      brandAppIds: {
        DeviceBrand.samsung: '111299001912',
        DeviceBrand.lg: 'youtube.leanback.v4',
        DeviceBrand.roku: '837',
        DeviceBrand.androidTv: 'com.google.android.youtube.tv',
        DeviceBrand.fireTv: 'com.amazon.firetv.youtube',
      },
    ),
    AppShortcut(
      id: 'primevideo',
      displayName: 'Prime Video',
      iconAssetOrName: 'video_library',
      brandAppIds: {
        DeviceBrand.samsung: '3201512006785',
        DeviceBrand.lg: 'amazon',
        DeviceBrand.roku: '13',
        DeviceBrand.androidTv: 'com.amazon.amazonvideo.livingroom',
        DeviceBrand.fireTv: 'com.amazon.avod',
      },
    ),
    AppShortcut(
      id: 'disneyplus',
      displayName: 'Disney+',
      iconAssetOrName: 'auto_awesome',
      brandAppIds: {
        DeviceBrand.samsung: '3201907019331',
        DeviceBrand.lg: 'disney',
        DeviceBrand.roku: '291097',
        DeviceBrand.androidTv: 'com.disney.disneyplus',
        DeviceBrand.fireTv: 'com.disney.disneyplus',
      },
    ),
    AppShortcut(
      id: 'appletv',
      displayName: 'Apple TV',
      iconAssetOrName: 'tv',
      brandAppIds: {
        DeviceBrand.samsung: '3201807016597',
        DeviceBrand.lg: 'appletv',
        DeviceBrand.roku: '551012',
        DeviceBrand.androidTv: 'com.apple.atve.androidtv.appletv',
        DeviceBrand.fireTv: 'com.apple.atve.amazon.appletv',
      },
    ),
    AppShortcut(
      id: 'spotify',
      displayName: 'Spotify',
      iconAssetOrName: 'music_note',
      brandAppIds: {
        DeviceBrand.samsung: '3201606009684',
        DeviceBrand.lg: 'spotify',
        DeviceBrand.roku: '19977',
        DeviceBrand.androidTv: 'com.spotify.tv.android',
        DeviceBrand.fireTv: 'com.spotify.tv.android',
      },
    ),
  ];
}
