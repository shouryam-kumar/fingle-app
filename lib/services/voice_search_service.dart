import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceSearchService {
  static final VoiceSearchService _instance = VoiceSearchService._internal();
  factory VoiceSearchService() => _instance;
  VoiceSearchService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Request microphone permission
      final permissionStatus = await Permission.microphone.request();
      if (permissionStatus != PermissionStatus.granted) {
        return false;
      }

      // Initialize speech to text
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
        },
      );

      return _isInitialized;
    } catch (e) {
      print('Error initializing voice search: $e');
      return false;
    }
  }

  Future<String?> startListening({
    Duration? timeout,
    Function(String)? onPartialResult,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }

    if (_isListening) {
      await stopListening();
    }

    String? finalResult;

    try {
      _isListening = true;
      
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            finalResult = result.recognizedWords;
          } else if (onPartialResult != null) {
            onPartialResult(result.recognizedWords);
          }
        },
        listenFor: timeout ?? const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        partialResults: true,
        localeId: 'en_US',
      );

      // Wait for listening to complete
      while (_speechToText.isListening) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _isListening = false;
      return finalResult;

    } catch (e) {
      print('Error during voice recognition: $e');
      _isListening = false;
      return null;
    }
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    _isListening = false;
  }

  Future<void> cancel() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
    _isListening = false;
  }

  Future<List<String>> getAvailableLocales() async {
    final locales = await _speechToText.locales();
    return locales.map((locale) => locale.localeId).toList();
  }

  bool get isAvailable => _speechToText.isAvailable;
  bool get hasError => _speechToText.hasError;
  String get lastError => _speechToText.lastError?.errorMsg ?? '';
}