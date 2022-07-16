// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:avatar_glow/avatar_glow.dart';

class Query extends StatefulWidget {
  const Query({Key? key}) : super(key: key);

  @override
  State<Query> createState() => _QueryState();
}

class _QueryState extends State<Query> {
  late stt.SpeechToText _speech;
  late bool _isListening = false;
  late String _text = "";
  late double _confidence = 1.0;
  @override
  void initState() {
    super.initState();

    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage("fr-FR");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(0.8);
    String toSay =
        "Bienvenue sur vocal earth, Appuyer sur le bouton pour nous dire un peu plus sur votre voyage. Appuyer une nouvelle fois pour arrêter.";
    Future.delayed(Duration(milliseconds: 1000), () {
      flutterTts.speak(toSay);
    });
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor = _isListening ? Colors.white : Colors.grey;
    Color bgColor =
        _isListening ? Color.fromARGB(255, 108, 160, 255) : Colors.white;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Parlez-nous de votre voyage'),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 108, 160, 255),
        ),
        body: Center(
          child: SizedBox(
              height: 200,
              width: 200,
              child: FloatingActionButton(
                  backgroundColor: bgColor,
                  onPressed: () {
                    _listen();
                  },
                  child: Icon(
                    Icons.flight_takeoff,
                    color: iconColor,
                    size: 90,
                  ))),
        ));
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      Future.delayed(Duration(milliseconds: 1500), () {
        Navigator.pushNamed(context, "/date", arguments: {
          "text": _text,
        });
      });
    }
  }
}
