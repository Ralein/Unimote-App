import '../../domain/entities/remote_key.dart';

enum CommandPayloadType {
  httpPath,
  jsonString,
  plainString,
  adbKeyCode,
  irData,
}

class CommandPayload {
  final CommandPayloadType type;
  final String value;

  const CommandPayload({
    required this.type,
    required this.value,
  });

  @override
  String toString() => 'CommandPayload(type: $type, value: $value)';
}

abstract class CommandMapper {
  CommandPayload mapKey(RemoteKey key);
}

class MockCommandMapper implements CommandMapper {
  @override
  CommandPayload mapKey(RemoteKey key) {
    return CommandPayload(
      type: CommandPayloadType.plainString,
      value: 'MOCK_KEY_${key.name.toUpperCase()}',
    );
  }
}

class RokuCommandMapper implements CommandMapper {
  @override
  CommandPayload mapKey(RemoteKey key) {
    String keyName;
    switch (key) {
      case RemoteKey.power:
        keyName = 'PowerOff';
        break;
      case RemoteKey.home:
        keyName = 'Home';
        break;
      case RemoteKey.back:
        keyName = 'Back';
        break;
      case RemoteKey.dpadUp:
        keyName = 'Up';
        break;
      case RemoteKey.dpadDown:
        keyName = 'Down';
        break;
      case RemoteKey.dpadLeft:
        keyName = 'Left';
        break;
      case RemoteKey.dpadRight:
        keyName = 'Right';
        break;
      case RemoteKey.select:
        keyName = 'Select';
        break;
      case RemoteKey.volumeUp:
        keyName = 'VolumeUp';
        break;
      case RemoteKey.volumeDown:
        keyName = 'VolumeDown';
        break;
      case RemoteKey.mute:
        keyName = 'VolumeMute';
        break;
      case RemoteKey.playPause:
        keyName = 'Play';
        break;
      case RemoteKey.inputSource:
        keyName = 'InputTuner';
        break;
      case RemoteKey.num0:
      case RemoteKey.num1:
      case RemoteKey.num2:
      case RemoteKey.num3:
      case RemoteKey.num4:
      case RemoteKey.num5:
      case RemoteKey.num6:
      case RemoteKey.num7:
      case RemoteKey.num8:
      case RemoteKey.num9:
        keyName = 'Lit_${key.displayName}';
        break;
    }
    return CommandPayload(
      type: CommandPayloadType.httpPath,
      value: '/keypress/$keyName',
    );
  }
}

class SamsungCommandMapper implements CommandMapper {
  @override
  CommandPayload mapKey(RemoteKey key) {
    String keyName;
    switch (key) {
      case RemoteKey.power:
        keyName = 'KEY_POWER';
        break;
      case RemoteKey.home:
        keyName = 'KEY_HOME';
        break;
      case RemoteKey.back:
        keyName = 'KEY_RETURN';
        break;
      case RemoteKey.dpadUp:
        keyName = 'KEY_UP';
        break;
      case RemoteKey.dpadDown:
        keyName = 'KEY_DOWN';
        break;
      case RemoteKey.dpadLeft:
        keyName = 'KEY_LEFT';
        break;
      case RemoteKey.dpadRight:
        keyName = 'KEY_RIGHT';
        break;
      case RemoteKey.select:
        keyName = 'KEY_ENTER';
        break;
      case RemoteKey.volumeUp:
        keyName = 'KEY_VOLUP';
        break;
      case RemoteKey.volumeDown:
        keyName = 'KEY_VOLDOWN';
        break;
      case RemoteKey.mute:
        keyName = 'KEY_MUTE';
        break;
      case RemoteKey.playPause:
        keyName = 'KEY_PLAY_BACK';
        break;
      case RemoteKey.inputSource:
        keyName = 'KEY_SOURCE';
        break;
      default:
        keyName = 'KEY_${key.displayName}';
        break;
    }
    return CommandPayload(
      type: CommandPayloadType.jsonString,
      value: keyName,
    );
  }
}

class LgCommandMapper implements CommandMapper {
  @override
  CommandPayload mapKey(RemoteKey key) {
    String keyName;
    switch (key) {
      case RemoteKey.power:
        keyName = 'POWER';
        break;
      case RemoteKey.home:
        keyName = 'HOME';
        break;
      case RemoteKey.back:
        keyName = 'BACK';
        break;
      case RemoteKey.dpadUp:
        keyName = 'UP';
        break;
      case RemoteKey.dpadDown:
        keyName = 'DOWN';
        break;
      case RemoteKey.dpadLeft:
        keyName = 'LEFT';
        break;
      case RemoteKey.dpadRight:
        keyName = 'RIGHT';
        break;
      case RemoteKey.select:
        keyName = 'ENTER';
        break;
      case RemoteKey.volumeUp:
        keyName = 'VOLUMEUP';
        break;
      case RemoteKey.volumeDown:
        keyName = 'VOLUMEDOWN';
        break;
      case RemoteKey.mute:
        keyName = 'MUTE';
        break;
      case RemoteKey.playPause:
        keyName = 'PLAY';
        break;
      default:
        keyName = key.name.toUpperCase();
        break;
    }
    return CommandPayload(
      type: CommandPayloadType.plainString,
      value: keyName,
    );
  }
}

class FireTvCommandMapper implements CommandMapper {
  @override
  CommandPayload mapKey(RemoteKey key) {
    int code;
    switch (key) {
      case RemoteKey.power:
        code = 26; // KEYCODE_POWER
        break;
      case RemoteKey.home:
        code = 3; // KEYCODE_HOME
        break;
      case RemoteKey.back:
        code = 4; // KEYCODE_BACK
        break;
      case RemoteKey.dpadUp:
        code = 19; // KEYCODE_DPAD_UP
        break;
      case RemoteKey.dpadDown:
        code = 20; // KEYCODE_DPAD_DOWN
        break;
      case RemoteKey.dpadLeft:
        code = 21; // KEYCODE_DPAD_LEFT
        break;
      case RemoteKey.dpadRight:
        code = 22; // KEYCODE_DPAD_RIGHT
        break;
      case RemoteKey.select:
        code = 66; // KEYCODE_ENTER
        break;
      case RemoteKey.volumeUp:
        code = 24; // KEYCODE_VOLUME_UP
        break;
      case RemoteKey.volumeDown:
        code = 25; // KEYCODE_VOLUME_DOWN
        break;
      case RemoteKey.mute:
        code = 164; // KEYCODE_VOLUME_MUTE
        break;
      case RemoteKey.playPause:
        code = 85; // KEYCODE_MEDIA_PLAY_PAUSE
        break;
      default:
        code = 0;
        break;
    }
    return CommandPayload(
      type: CommandPayloadType.adbKeyCode,
      value: code.toString(),
    );
  }
}
