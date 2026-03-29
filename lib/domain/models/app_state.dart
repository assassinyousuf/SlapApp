class AppState {
  final double sensitivity;
  final bool aiModeEnabled;
  final String selectedSoundPack;
  final int totalSlaps;
  final double averageIntensity;

  AppState({
    this.sensitivity = 20.0,
    this.aiModeEnabled = false,
    this.selectedSoundPack = 'default',
    this.totalSlaps = 0,
    this.averageIntensity = 0.0,
  });

  AppState copyWith({
    double? sensitivity,
    bool? aiModeEnabled,
    String? selectedSoundPack,
    int? totalSlaps,
    double? averageIntensity,
  }) {
    return AppState(
      sensitivity: sensitivity ?? this.sensitivity,
      aiModeEnabled: aiModeEnabled ?? this.aiModeEnabled,
      selectedSoundPack: selectedSoundPack ?? this.selectedSoundPack,
      totalSlaps: totalSlaps ?? this.totalSlaps,
      averageIntensity: averageIntensity ?? this.averageIntensity,
    );
  }
}
