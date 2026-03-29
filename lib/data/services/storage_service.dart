import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> writeCsvFile(String filename, String content) async {
    final path = await _localPath;
    final file = File('$path/$filename');
    
    // Write the file
    return file.writeAsString(content);
  }

  Future<List<File>> getDatasetFiles() async {
    final path = await _localPath;
    final directory = Directory(path);
    
    if (!await directory.exists()) return [];

    final files = directory.listSync().whereType<File>().toList();
    return files.where((f) => f.path.endsWith('.csv')).toList();
  }
}
