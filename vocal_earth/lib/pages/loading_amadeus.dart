import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AmadeusLoading extends StatefulWidget {
  const AmadeusLoading({Key? key}) : super(key: key);

  @override
  State<AmadeusLoading> createState() => _AmadeusLoadingState();
}

class _AmadeusLoadingState extends State<AmadeusLoading> {
  Map data = {};
  void initState() {
    super.initState();

    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage("fr-FR");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(0.8);
    String toSay =
        "Nous sommes en train de récuperer les billets correspondants à votre recherche. Veuillez patienter.";
    Future.delayed(Duration(milliseconds: 1000), () {
      flutterTts.speak(toSay);
    });
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)?.settings.arguments as Map;
    return Scaffold(
      body: Center(
          child: SpinKitWave(
        color: const Color.fromARGB(255, 108, 160, 255),
        size: 90.0,
      )),
    );
  }
}
