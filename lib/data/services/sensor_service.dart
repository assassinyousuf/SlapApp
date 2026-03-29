import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../../domain/models/sensor_data.dart';

class SensorService {
  StreamSubscription? _accelSub;

  final _sensorStreamController = StreamController<SensorData>.broadcast();

  Stream<SensorData> get sensorStream => _sensorStreamController.stream;

  void startListening() {
    // Some devices do not have a dedicated linear userAccelerometer so it silently fails.
    // accelerometerEventStream is purely raw hardware and exists on 100% of devices.
    _accelSub = accelerometerEventStream().listen((event) {
      _sensorStreamController.add(SensorData(
        ax: event.x,
        ay: event.y,
        az: event.z,
        gx: 0, gy: 0, gz: 0, // Not needed anymore for simple hit detection
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    });
  }

  void stopListening() {
    _accelSub?.cancel();
    _accelSub = null;
  }
}
