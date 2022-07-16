import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Escale extends StatefulWidget {
  const Escale({Key? key}) : super(key: key);

  @override
  State<Escale> createState() => _EscaleState();
}

class _EscaleState extends State<Escale> {
  Map data = {};
  String _escale = "false";
  void initState() {
    super.initState();

    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage("fr-FR");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(0.8);
    String toSay =
        "D'accord, Voulez-vous un vol en escale? Appuyer sur le bouton oui ou non puis appuyer sur le bouton Rechercher pour lancer votre recherche.";
    Future.delayed(Duration(milliseconds: 1000), () {
      flutterTts.speak(toSay);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color colorYes = _escale == "true"
        ? const Color.fromARGB(255, 108, 160, 255)
        : Color.fromARGB(57, 149, 149, 149);

    Color colorNo = _escale == "false"
        ? const Color.fromARGB(255, 108, 160, 255)
        : Color.fromARGB(57, 149, 149, 149);
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)?.settings.arguments as Map;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voulez-vous un vol en escale?'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 108, 160, 255),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: colorNo,
                    ),
                    onPressed: () {
                      setState(() {
                        _escale = "false";
                      });
                    },
                    child: Text("Non", style: TextStyle(fontSize: 20.0)),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: colorYes,
                    ),
                    onPressed: () {
                      setState(() {
                        _escale = "true";
                      });
                    },
                    child: Text("Oui", style: TextStyle(fontSize: 20.0)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 100,
        width: 200,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color.fromARGB(255, 108, 160, 255),
          ),
          child: Text('Rechercher', style: TextStyle(fontSize: 30.0)),
          onPressed: () {
            Future.delayed(Duration(milliseconds: 1000), () {
              print(_escale);
              Navigator.pushNamed(context, "/loading", arguments: {
                "text": data["text"],
                "date": data["date"],
                "nbPassenger": data["nbPassenger"],
                "escale": _escale
              });
            });
          },
        ),
      ),
    );
  }
}
