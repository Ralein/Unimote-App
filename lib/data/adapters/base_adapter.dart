import 'dart:async';
import '../../domain/entities/adapter_state.dart';
import '../../domain/repositories/remote_adapter.dart';

abstract class BaseAdapter implements RemoteAdapter {
  final StreamController<AdapterState> stateController =
      StreamController<AdapterState>.broadcast();
  AdapterState internalState = const AdapterState.disconnected();

  @override
  AdapterState get currentState => internalState;

  @override
  Stream<AdapterState> get state => stateController.stream;

  void emitState(AdapterState newState) {
    internalState = newState;
    stateController.add(newState);
  }

  void dispose() {
    stateController.close();
  }
}
