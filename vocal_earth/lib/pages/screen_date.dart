import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:avatar_glow/avatar_glow.dart';

class Date extends StatefulWidget {
  const Date({Key? key}) : super(key: key);

  @override
  State<Date> createState() => _DateState();
}

class _DateState extends State<Date> {
  late stt.SpeechToText _speech;
  late bool _isListening = false;
  late String _date = "";
  late double _confidence = 1.0;
  Map data = {};
  void initState() {
    super.initState();

    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage("fr-FR");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(0.8);
    String toSay =
        "Très bien votre trajet a été pris en compte, Appuyer sur le bouton pour nous dire quand voulez-vous voyager. Appuyer une nouvelle fois pour arrêter.";
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
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)?.settings.arguments as Map;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Quand voulez-vous voyager?'),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 108, 160, 255),
        ),
        body: Center(
          child: SizedBox(
              height: 200,
              width: 200,
              child: FloatingActionButton(
                  heroTag: "btn1",
                  backgroundColor: bgColor,
                  onPressed: () {
                    _listen();
                  },
                  child: Icon(
                    Icons.calendar_month,
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
            _date = val.recognizedWords;
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
        Navigator.pushNamed(context, "/nbpassenger", arguments: {
          "text": data["text"],
          "date": _date,
        });
      });
    }
  }
}
