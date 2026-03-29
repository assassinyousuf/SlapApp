import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  int _lastPlayTime = 0;
  final Random _random = Random();
  
  List<String> _funnyLibrary = [
    'soft_slap.mp3',
    'medium_slap.mp3',
    'explosion.mp3',
  ];

  AudioService() {
    _loadAssetList();
  }

  Future<void> _loadAssetList() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final soundPaths = manifestMap.keys
          .where((String key) => key.startsWith('assets/sounds/') && key.endsWith('.mp3'))
          .map((String key) => key.substring(14)) // removes 'assets/sounds/'
          .toList();
          
      if (soundPaths.isNotEmpty) {
        _funnyLibrary = soundPaths;
      }
    } catch (e) {
      // Keep hardcoded fallbacks if manifest parsing fails
    }
  }

  Future<void> playSoundForIntensity(double intensity) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    // 250ms cooldown to avoid overlapping sample spam too fast, but allow quick rapid hits
    if (now - _lastPlayTime < 250) return;

    // Grab a totally random silly sound!
    String soundFile = _funnyLibrary[_random.nextInt(_funnyLibrary.length)];

    try {
      // Fire and forget mechanism guarantees the sound will play, completely ignoring playstate bugs
      final player = AudioPlayer();
      await player.play(AssetSource('sounds/$soundFile'));
      _lastPlayTime = now;
      
      // Auto-dispose to free memory
      player.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          player.dispose();
        }
      });
    } catch (e) {
      // Ignored dummy file playback errors
    }
  }
}
