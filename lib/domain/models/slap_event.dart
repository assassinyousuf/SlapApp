class SlapEvent {
  final double intensity;
  final String direction;
  final double distanceScore;
  final int timestamp;
  final String label;

  SlapEvent({
    required this.intensity,
    required this.direction,
    required this.distanceScore,
    required this.timestamp,
    required this.label,
  });
}
