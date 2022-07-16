// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NbPassenger extends StatefulWidget {
  const NbPassenger({Key? key}) : super(key: key);

  @override
  State<NbPassenger> createState() => _NbPassengerState();
}

class _NbPassengerState extends State<NbPassenger> {
  Map data = {};
  int _nbPassenger = 1;
  void initState() {
    super.initState();

    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage("fr-FR");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(0.8);
    String toSay =
        "Très bien votre date de voyage a été pris en compte, Appuyer sur le bouton plus ou moins pour ajouter ou diminuer le nombre de passager. Appuyer sur le bouton valider pour poursuivre.";
    Future.delayed(Duration(milliseconds: 1000), () {
      flutterTts.speak(toSay);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color colorMain = const Color.fromARGB(255, 108, 160, 255);
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)?.settings.arguments as Map;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Combien de passager?'),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 108, 160, 255),
        ),
        body: Container(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "btn2",
                  onPressed: minus,
                  child: Icon(
                    Icons.remove,
                    color: Colors.black,
                  ),
                  backgroundColor: Colors.white,
                ),
                Text('$_nbPassenger', style: TextStyle(fontSize: 60.0)),
                FloatingActionButton(
                  heroTag: "btn1",
                  onPressed: add,
                  child: Icon(Icons.add, color: Colors.black),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          height: 200,
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: colorMain,
                ),
                child: Text('Valider', style: TextStyle(fontSize: 30.0)),
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 1000), () {
                    Navigator.pushNamed(context, "/escale", arguments: {
                      "text": data["text"],
                      "date": data["date"],
                      "nbPassenger": _nbPassenger
                    });
                  });
                  ;
                }),
          ),
        ));
  }

  void add() {
    setState(() {
      if (_nbPassenger < 6) _nbPassenger++;
    });
  }

  void minus() {
    setState(() {
      if (_nbPassenger != 1) _nbPassenger--;
    });
  }
}
