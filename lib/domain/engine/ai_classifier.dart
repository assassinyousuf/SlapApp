import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/sensor_data.dart';

class AiClassifier {
  Interpreter? _interpreter;
  bool _isReady = false;

  final int _timesteps = 100;
  final int _features = 6;
  
  // Aligning with Python CNN classes
  final List<String> _labels = ['slap', 'hit', 'drop', 'shake', 'idle'];

  AiClassifier() {
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/slap_model.tflite');
      _isReady = true;
      debugPrint('TFLite model loaded successfully.');
    } catch (e) {
      debugPrint('Error loading model: $e');
      _isReady = false; // Fallback to rule-based naturally
    }
  }

  /// Returns a map of label probabilities or null if ML isn't ready
  Future<Map<String, double>?> predict(List<SensorData> sequence) async {
    if (!_isReady || _interpreter == null) return null;
    if (sequence.length < _timesteps) return null;

    // Grab the last 100 frames
    final window = sequence.sublist(sequence.length - _timesteps);

    // Normalize and reshape
    // Shape required: [1, 100, 6]
    var input = List.generate(1, (i) => List.generate(_timesteps, (j) => List.filled(_features, 0.0)));
    
    for (int i = 0; i < _timesteps; i++) {
        input[0][i][0] = window[i].ax;
        input[0][i][1] = window[i].ay;
        input[0][i][2] = window[i].az;
        input[0][i][3] = window[i].gx;
        input[0][i][4] = window[i].gy;
        input[0][i][5] = window[i].gz;
    }

    // Output shape: [1, 5]
    var output = List.generate(1, (i) => List.filled(_labels.length, 0.0));

    try {
      _interpreter!.run(input, output);
      
      Map<String, double> results = {};
      for (int i = 0; i < _labels.length; i++) {
        results[_labels[i]] = output[0][i];
      }
      return results;
    } catch (e) {
      debugPrint('Inference error: $e');
      return null;
    }
  }
}
