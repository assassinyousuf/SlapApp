import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/sensor_service.dart';
import '../data/services/audio_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/dataset_recorder.dart';
import '../domain/models/app_state.dart';
import 'controllers/slap_controller.dart';
import 'controllers/dataset_controller.dart';

// -- Services --
final sensorServiceProvider = Provider<SensorService>((ref) => SensorService());
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final datasetRecorderProvider = Provider<DatasetRecorder>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DatasetRecorder(storage);
});

// -- App State --
class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() => AppState();

  void updateState(AppState newState) {
    state = newState;
  }
}

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(AppStateNotifier.new);

// -- Controllers --
final slapControllerProvider = NotifierProvider<SlapController, SlapState>(SlapController.new);

final datasetControllerProvider = NotifierProvider<DatasetController, DatasetState>(DatasetController.new);
