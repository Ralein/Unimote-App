import 'remote_key.dart';

enum MacroStepType {
  sendKey,
  sendText,
  launchApp,
  delay,
}

class MacroStep {
  final MacroStepType type;
  final RemoteKey? key;
  final String? textPayload;
  final String? appId;
  final Duration? delayDuration;

  const MacroStep.key(this.key)
      : type = MacroStepType.sendKey,
        textPayload = null,
        appId = null,
        delayDuration = null;

  const MacroStep.text(this.textPayload)
      : type = MacroStepType.sendText,
        key = null,
        appId = null,
        delayDuration = null;

  const MacroStep.app(this.appId)
      : type = MacroStepType.launchApp,
        key = null,
        textPayload = null,
        delayDuration = null;

  const MacroStep.delay(this.delayDuration)
      : type = MacroStepType.delay,
        key = null,
        textPayload = null,
        appId = null;

  String get description {
    switch (type) {
      case MacroStepType.sendKey:
        return 'Send ${key?.displayName ?? "Key"}';
      case MacroStepType.sendText:
        return 'Text "$textPayload"';
      case MacroStepType.launchApp:
        return 'Launch App "$appId"';
      case MacroStepType.delay:
        return 'Wait ${delayDuration?.inSeconds ?? 1}s';
    }
  }
}

class Macro {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final List<MacroStep> steps;

  const Macro({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.steps,
  });
}
