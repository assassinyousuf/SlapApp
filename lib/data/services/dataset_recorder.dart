import 'dart:io';
import 'package:csv/csv.dart';
import '../../domain/models/sensor_data.dart';
import 'storage_service.dart';

class DatasetRecorder {
  final StorageService _storageService;

  DatasetRecorder(this._storageService);

  Future<File?> saveSequence(List<SensorData> sequence, String label) async {
    if (sequence.isEmpty) return null;

    List<List<dynamic>> rows = [];
    
    // Header
    rows.add(['ax', 'ay', 'az', 'gx', 'gy', 'gz', 'timestamp', 'label']);
    
    // Data
    for (var data in sequence) {
      rows.add(data.toCsvRow(label));
    }

    String csv = const ListToCsvConverter().convert(rows);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = '${label.toLowerCase()}_$timestamp.csv';

    return await _storageService.writeCsvFile(filename, csv);
  }
}
