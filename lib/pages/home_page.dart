import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:taasitant/services/speech_to_text_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SpeechToTextService speechToTextService;
  String recognitionText = '...';
  String? _currentLocalId;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speechToTextService = SpeechToTextService();
  }

  Widget _buildListening() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Text(
          recognitionText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 50.0,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  void resultListener(SpeechRecognitionResult result) {
    if (kDebugMode) {
      print('result $result');
    }
    setState(() {
      recognitionText = result.recognizedWords;
    });
  }

  void soundLevelListener(double level) {
  //  print('sound level: $level');
  }

  Future<bool> initializeSpeechToTextService() async {
    speechToTextService.initialSpeechToText();
    _currentLocalId = await speechToTextService.getCurrentLocaleId();
    // _startListen();
    return true;
  }

  void _startListen(){
    if (_currentLocalId == null) {
      return;
    }

    speechToTextService.startListening(
      resultListener: resultListener,
      soundLevelListener: soundLevelListener,
      currentLocaleId: _currentLocalId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: initializeSpeechToTextService(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
                return _buildListening();
            }
            return _buildLoading();
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Text(isListening ? 'Stop' : 'Start'),
          onPressed: () {
            if (isListening) {
              speechToTextService.stopListening();
              speechToTextService.cancelListening();
              setState(() {
                recognitionText = '...';
              });
            } else {
              _startListen();
            }
            setState(() {
              isListening = !isListening;
            });
          },
        ),
      ),
    );
  }
}
