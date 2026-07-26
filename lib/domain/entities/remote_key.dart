enum RemoteKey {
  power,
  home,
  back,
  dpadUp,
  dpadDown,
  dpadLeft,
  dpadRight,
  select,
  volumeUp,
  volumeDown,
  mute,
  playPause,
  num0,
  num1,
  num2,
  num3,
  num4,
  num5,
  num6,
  num7,
  num8,
  num9,
  inputSource;

  bool get isNumeric {
    return index >= RemoteKey.num0.index && index <= RemoteKey.num9.index;
  }

  String get displayName {
    switch (this) {
      case RemoteKey.power:
        return 'Power';
      case RemoteKey.home:
        return 'Home';
      case RemoteKey.back:
        return 'Back';
      case RemoteKey.dpadUp:
        return 'Up';
      case RemoteKey.dpadDown:
        return 'Down';
      case RemoteKey.dpadLeft:
        return 'Left';
      case RemoteKey.dpadRight:
        return 'Right';
      case RemoteKey.select:
        return 'Select';
      case RemoteKey.volumeUp:
        return 'Vol +';
      case RemoteKey.volumeDown:
        return 'Vol -';
      case RemoteKey.mute:
        return 'Mute';
      case RemoteKey.playPause:
        return 'Play/Pause';
      case RemoteKey.inputSource:
        return 'Input';
      case RemoteKey.num0:
        return '0';
      case RemoteKey.num1:
        return '1';
      case RemoteKey.num2:
        return '2';
      case RemoteKey.num3:
        return '3';
      case RemoteKey.num4:
        return '4';
      case RemoteKey.num5:
        return '5';
      case RemoteKey.num6:
        return '6';
      case RemoteKey.num7:
        return '7';
      case RemoteKey.num8:
        return '8';
      case RemoteKey.num9:
        return '9';
    }
  }
}
