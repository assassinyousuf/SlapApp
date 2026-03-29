import 'dart:math';
import '../models/sensor_data.dart';

class MotionAnalyzer {
  static double calculateMagnitude(double x, double y, double z) {
    return sqrt((x * x) + (y * y) + (z * z));
  }

  static double calculateIntensity(SensorData data) {
    // Since we now use userAccelerometer, gravity is already removed automatically!
    return calculateMagnitude(data.ax, data.ay, data.az);
  }

  static String determineDominantAxis(SensorData data) {
    double ax = data.ax.abs();
    double ay = data.ay.abs();
    double az = data.az.abs();

    if (ax > ay && ax > az) return 'X';
    if (ay > ax && ay > az) return 'Y';
    return 'Z';
  }
}
