class SensorData {
  final double ax;
  final double ay;
  final double az;
  final double gx;
  final double gy;
  final double gz;
  final int timestamp;

  SensorData({
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
    required this.timestamp,
  });

  factory SensorData.empty() => SensorData(
    ax: 0, ay: 0, az: 0, 
    gx: 0, gy: 0, gz: 0, 
    timestamp: DateTime.now().millisecondsSinceEpoch
  );

  List<dynamic> toCsvRow(String label) {
    return [ax, ay, az, gx, gy, gz, timestamp, label];
  }

  SensorData copyWith({
    double? ax,
    double? ay,
    double? az,
    double? gx,
    double? gy,
    double? gz,
    int? timestamp,
  }) {
    return SensorData(
      ax: ax ?? this.ax,
      ay: ay ?? this.ay,
      az: az ?? this.az,
      gx: gx ?? this.gx,
      gy: gy ?? this.gy,
      gz: gz ?? this.gz,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
