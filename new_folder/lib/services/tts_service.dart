// lib/services/tts_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService with ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  String _currentlyPlayingId = '';

  bool get isPlaying => _isPlaying;
  String get currentlyPlayingId => _currentlyPlayingId;

  TtsService() {
    // Listen for the completion of speech to reset the state
    _flutterTts.setCompletionHandler(() {
      _resetState();
    });

    // Listen for errors to reset the state
    _flutterTts.setErrorHandler((_) {
      _resetState();
    });
  }

  void _resetState() {
    _isPlaying = false;
    _currentlyPlayingId = '';
    notifyListeners();
  }

  Future<void> speak(String text, String itemId) async {
    if (_isPlaying) {
      await stop();
      // If the user tapped the same item that was playing, just stop it.
      if (_currentlyPlayingId == itemId) {
        return;
      }
    }
    
    _isPlaying = true;
    _currentlyPlayingId = itemId;
    notifyListeners();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _resetState();
  }
}