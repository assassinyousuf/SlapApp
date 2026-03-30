import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AiService {
  static Future<String?> generateSadFace(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        // 10.0.2.2 points to localhost from the Android Emulator!
        Uri.parse('http://10.0.2.2:5000/sad'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final dir = await getTemporaryDirectory();
        final outFile = File('${dir.path}/sad_face_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await outFile.writeAsBytes(bytes);
        return outFile.path;
      }
    } catch (e) {
      debugPrint('AI Server Error: $e');
    }
    return null;
  }
}
