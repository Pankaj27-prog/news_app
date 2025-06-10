import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  TTSService() {
    _initTTS();
  }

  Future<void> _initTTS() async {
    // Set to Indian English
    await _flutterTts.setLanguage("en-IN");
    await _flutterTts.setSpeechRate(0.7); // Moderate speed for Indian English
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.1); // Slightly higher pitch for Indian female voice
    
    // Get available voices and set an Indian female voice
    final voices = await _flutterTts.getVoices;
    final indianVoice = voices.firstWhere(
      (voice) => voice['name'].toString().toLowerCase().contains('indian') ||
                 voice['name'].toString().toLowerCase().contains('female') ||
                 voice['name'].toString().toLowerCase().contains('hi-IN'),
      orElse: () => voices.first,
    );
    
    await _flutterTts.setVoice({"name": indianVoice['name'], "locale": indianVoice['locale']});
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