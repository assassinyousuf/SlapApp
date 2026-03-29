
import '../models/sensor_data.dart';
import '../models/slap_event.dart';
import 'motion_analyzer.dart';

class SlapDetector {
  int _timeoutUntilNextActivation = 0;

  SlapEvent? detectOriginal(List<SensorData> buffer, double threshold) {
    if (buffer.isEmpty) return null;

    if (_timeoutUntilNextActivation > 0) {
      _timeoutUntilNextActivation--;
      return null;
    }

    final latestReading = buffer.last;
    final intensity = MotionAnalyzer.calculateIntensity(latestReading);

    // Simplify: just detect pure sudden spike! 
    // Works perfectly whether held in hand or sitting on a table.
    if (intensity > threshold) {
      // Detected a slap
      _timeoutUntilNextActivation = 35; // wait ~700ms before another slap

      return SlapEvent(
        intensity: intensity,
        direction: MotionAnalyzer.determineDominantAxis(latestReading),
        distanceScore: 0.0,
        timestamp: latestReading.timestamp,
        label: 'Slap', 
      );
    }

    return null;
  }
}
