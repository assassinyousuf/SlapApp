class AppConstants {
  static const double defaultSlapThreshold = 25.0; // Works with standard accelerometer 9.8 baseline!
  static const int bufferSequenceLengthMs = 2000;
  static const int sensorPollingRateMs = 20; // ~50Hz

  static const List<String> availableLabels = [
    'Slap',
    'Drop',
    'Shake',
    'Normal',
    'Idle'
  ];
}
