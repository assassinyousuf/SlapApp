import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/utils/circular_buffer.dart';
import '../../domain/models/sensor_data.dart';
import '../../domain/models/slap_event.dart';
import '../../domain/engine/slap_detector.dart';
import '../../data/services/sensor_service.dart';
import '../../data/services/audio_service.dart';
import '../providers.dart';

class SlapState {
  final SlapEvent? lastSlap;
  final num currentIntensity;
  final String status;

  SlapState({
    this.lastSlap,
    this.currentIntensity = 0,
    this.status = 'Idle',
  });

  SlapState copyWith({
    SlapEvent? lastSlap,
    num? currentIntensity,
    String? status,
  }) {
    return SlapState(
      lastSlap: lastSlap ?? this.lastSlap,
      currentIntensity: currentIntensity ?? this.currentIntensity,
      status: status ?? this.status,
    );
  }
}

class SlapController extends Notifier<SlapState> {
  late final SensorService _sensorService;
  late final AudioService _audioService;
  late final SlapDetector _slapDetector;

  final CircularBuffer<SensorData> sensorBuffer = CircularBuffer<SensorData>(100);
  bool _mounted = true;

  @override
  SlapState build() {
    _sensorService = ref.watch(sensorServiceProvider);
    _audioService = ref.watch(audioServiceProvider);
    _slapDetector = SlapDetector();
    
    ref.onDispose(() {
      _mounted = false;
      _sensorService.stopListening();
    });
    
    // Auto start detection immediately!
    Future.microtask(_startDetection);
    
    return SlapState();
  }

  void _startDetection() {
    state = state.copyWith(status: 'Listening...');
    _sensorService.startListening();
    _sensorService.sensorStream.listen(_onSensorData);
  }

  void _onSensorData(SensorData data) async {
    if (!_mounted) return;
    sensorBuffer.add(data);

    final event = _slapDetector.detectOriginal(
      sensorBuffer.toList,
      AppConstants.defaultSlapThreshold,
    );

    if (event != null) {
      _audioService.playSoundForIntensity(event.intensity);
      
      if (!_mounted) return;
      state = state.copyWith(
        lastSlap: event,
        currentIntensity: event.intensity,
        status: 'Slapped!',
      );

      // Flash animation timeout
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_mounted && state.status == 'Slapped!') {
          state = state.copyWith(status: 'Listening...');
        }
      });
    }
  }
}
