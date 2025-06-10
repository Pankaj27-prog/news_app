import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  TTSService() {
    _initTTS();
  }

  Future<void> _initTTS() async {
    // Set to US English for better web compatibility
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5); // Slower speed for better clarity
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0); // Neutral pitch
    
    // Get available voices
    final voices = await _flutterTts.getVoices;
    if (voices.isNotEmpty) {
      // Try to find a female voice, fallback to first available
      final femaleVoice = voices.firstWhere(
        (voice) => voice['name'].toString().toLowerCase().contains('female'),
        orElse: () => voices.first,
      );
      
      await _flutterTts.setVoice({"name": femaleVoice['name'], "locale": femaleVoice['locale']});
    }
  }

  Future<void> speak(String text) async {
    if (_isPlaying) {
      await stop();
    }
    
    try {
      _isPlaying = true;
      await _flutterTts.speak(text);
    } catch (e) {
      _isPlaying = false;
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
    } catch (e) {
      _isPlaying = false;
      rethrow;
    }
  }

  bool get isPlaying => _isPlaying;

  Future<void> dispose() async {
    await _flutterTts.stop();
  }
} 