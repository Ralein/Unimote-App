import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/macro.dart';
import '../../domain/entities/remote_key.dart';
import '../../domain/repositories/remote_adapter.dart';

class MacroState {
  final List<Macro> macros;
  final bool isExecuting;
  final String? executingMacroId;
  final int currentStepIndex;

  const MacroState({
    this.macros = const [],
    this.isExecuting = false,
    this.executingMacroId,
    this.currentStepIndex = 0,
  });

  MacroState copyWith({
    List<Macro>? macros,
    bool? isExecuting,
    String? executingMacroId,
    int? currentStepIndex,
  }) {
    return MacroState(
      macros: macros ?? this.macros,
      isExecuting: isExecuting ?? this.isExecuting,
      executingMacroId: executingMacroId,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }
}

class MacroNotifier extends Notifier<MacroState> {
  static final List<Macro> defaultMacros = [
    const Macro(
      id: 'macro-movie-night',
      name: 'Movie Night Sequence',
      description: 'Power On → Wait 2s → Switch Input 1 → Launch Netflix',
      iconName: 'movie',
      steps: [
        MacroStep.key(RemoteKey.power),
        MacroStep.delay(Duration(seconds: 2)),
        MacroStep.key(RemoteKey.inputSource),
        MacroStep.app('com.netflix.ninja'),
      ],
    ),
    const Macro(
      id: 'macro-gaming-mode',
      name: 'Gaming Mode',
      description: 'Power On → Wait 1s → Switch HDMI 2 → Vol Up x3',
      iconName: 'gamepad',
      steps: [
        MacroStep.key(RemoteKey.power),
        MacroStep.delay(Duration(seconds: 1)),
        MacroStep.key(RemoteKey.inputSource),
        MacroStep.key(RemoteKey.volumeUp),
        MacroStep.key(RemoteKey.volumeUp),
        MacroStep.key(RemoteKey.volumeUp),
      ],
    ),
  ];

  @override
  MacroState build() {
    return MacroState(macros: defaultMacros);
  }

  void addMacro(Macro macro) {
    state = state.copyWith(
      macros: [...state.macros, macro],
    );
  }

  Future<void> executeMacro(Macro macro, RemoteAdapter adapter) async {
    if (state.isExecuting) return;

    state = state.copyWith(
      isExecuting: true,
      executingMacroId: macro.id,
      currentStepIndex: 0,
    );

    for (int i = 0; i < macro.steps.length; i++) {
      if (!state.isExecuting) break;

      state = state.copyWith(currentStepIndex: i);
      final step = macro.steps[i];

      switch (step.type) {
        case MacroStepType.sendKey:
          if (step.key != null) {
            await adapter.sendKey(step.key!);
          }
          break;
        case MacroStepType.sendText:
          if (step.textPayload != null) {
            await adapter.sendText(step.textPayload!);
          }
          break;
        case MacroStepType.launchApp:
          if (step.appId != null) {
            await adapter.launchApp(step.appId!);
          }
          break;
        case MacroStepType.delay:
          if (step.delayDuration != null) {
            await Future.delayed(step.delayDuration!);
          }
          break;
      }
    }

    state = state.copyWith(
      isExecuting: false,
      executingMacroId: null,
      currentStepIndex: 0,
    );
  }

  void stopMacro() {
    state = state.copyWith(
      isExecuting: false,
      executingMacroId: null,
      currentStepIndex: 0,
    );
  }
}

final macroProvider =
    NotifierProvider<MacroNotifier, MacroState>(MacroNotifier.new);
