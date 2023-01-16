import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

const Duration listenFor = Duration(minutes: 1);
const Duration pauseFor = Duration(minutes: 1);

/// Using https://pub.dev/packages/speech_to_text
class SpeechToTextService {
  SpeechToTextService() {
    _speech = SpeechToText();
  }

  late final SpeechToText _speech;

  Future<bool> initialSpeechToText({
     SpeechErrorListener? onError,
     SpeechStatusListener? onStatus,
  }) async {
    final hasSpeech = await _speech.initialize(
      onError: onError,
      onStatus: onStatus,
    );
    return hasSpeech;
  }

  Future<String?> getCurrentLocaleId() async {
    final systemLocale = await _speech.systemLocale();
    final currentLocaleId = systemLocale?.localeId;
    return currentLocaleId;
  }

  void startListening({
    required Function(SpeechRecognitionResult result) resultListener,
    required Function(double level) soundLevelListener,
    required String currentLocaleId,
  }) {
    // Note that `listenFor` is the maximum, not the minimum, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    _speech.listen(
      onResult: resultListener,
      listenFor: listenFor,
      pauseFor: pauseFor,
      partialResults: true,
      localeId: currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      cancelOnError: true,
      listenMode: ListenMode.dictation,
    );
  }

  void stopListening() {
    _speech.stop();
  }

  void cancelListening() {
    _speech.cancel();
  }
}
