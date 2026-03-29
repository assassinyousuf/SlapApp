import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../core/utils/circular_buffer.dart';
import '../../domain/models/sensor_data.dart';
import '../../data/services/sensor_service.dart';
import '../../data/services/dataset_recorder.dart';
import '../providers.dart';

class DatasetState {
  final bool isRecording;
  final List<SensorData> graphData;
  final String lastSavedFile;

  DatasetState({
    this.isRecording = false,
    this.graphData = const [],
    this.lastSavedFile = '',
  });

  DatasetState copyWith({
    bool? isRecording,
    List<SensorData>? graphData,
    String? lastSavedFile,
  }) {
    return DatasetState(
      isRecording: isRecording ?? this.isRecording,
      graphData: graphData ?? this.graphData,
      lastSavedFile: lastSavedFile ?? this.lastSavedFile,
    );
  }
}

class DatasetController extends Notifier<DatasetState> {
  late final SensorService _sensorService;
  late final DatasetRecorder _datasetRecorder;
  
  // High capacity for dataset buffer: 3 seconds at 50Hz = 150 samples
  final CircularBuffer<SensorData> _buffer = CircularBuffer<SensorData>(150);

  bool _mounted = true;

  @override
  DatasetState build() {
    _sensorService = ref.watch(sensorServiceProvider);
    _datasetRecorder = ref.watch(datasetRecorderProvider);
    
    ref.onDispose(() {
      _mounted = false;
      _sensorService.stopListening();
    });
    
    return DatasetState();
  }

  void toggleRecording() {
    if (state.isRecording) {
      _sensorService.stopListening();
      state = state.copyWith(isRecording: false);
    } else {
      _buffer.clear();
      _sensorService.startListening();
      _sensorService.sensorStream.listen(_onData);
      state = state.copyWith(isRecording: true, lastSavedFile: '');
    }
  }

  void _onData(SensorData data) {
    if (!_mounted) return;
    _buffer.add(data);
    // update real-time graph with last N samples
    state = state.copyWith(graphData: _buffer.toList);
  }

  Future<void> saveLabelAndExport(String label) async {
    if (!state.isRecording) return;
    
    // We grab the current buffer *before* stopping to ensure we get 
    // the previous N seconds strictly before the button press
    List<SensorData> sequenceToSave = _buffer.toList;
    
    File? file = await _datasetRecorder.saveSequence(sequenceToSave, label);
    
    if (file != null) {
      state = state.copyWith(lastSavedFile: file.path.split('/').last);
      // clear buffer so next label doesn't contain overlapping event data
      _buffer.clear(); 
    }
  }
}
