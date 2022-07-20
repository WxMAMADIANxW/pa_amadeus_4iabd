import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocal_earth/services/amadeus.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({Key? key}) : super(key: key);

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  Map data = {};
  List<Ticket> body = [];
  void initState() {
    super.initState();

    FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage("fr-FR");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(0.8);
    String toSay =
        "Voici les billets que nous avons trouvé pour vous. Cliquez sur un billet pour entendre ses informations.";
    Future.delayed(Duration(milliseconds: 1000), () {
      flutterTts.speak(toSay);
    });
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)?.settings.arguments as Map;
    body = data["body"] as List<Ticket>;
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("Billets"),
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(
        title: Text("Billets"),
      ),
      body: ListView.builder(
        itemCount: body.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(body[index].title),
            subtitle: Text(body[index].subtitle),
            onTap: () {
              FlutterTts flutterTts = FlutterTts();
              flutterTts.setLanguage("fr-FR");
              flutterTts.setSpeechRate(0.5);
              flutterTts.setPitch(0.8);
              String toSay = body[index].description;
              flutterTts.speak(toSay);
            },
          );
        },
      ),
    );
  }
}
