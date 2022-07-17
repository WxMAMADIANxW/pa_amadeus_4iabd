import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:vocal_earth/services/amadeus.dart';

class AmadeusLoading extends StatefulWidget {
  const AmadeusLoading({Key? key}) : super(key: key);

  @override
  State<AmadeusLoading> createState() => _AmadeusLoadingState();
}

class _AmadeusLoadingState extends State<AmadeusLoading> {
  Map data = {};

  List<Ticket> parseTickets(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Ticket>((json) => Ticket.fromJson(json)).toList();
  }

  Future<List<Ticket>> fetchTickets(data) async {
    final response = await post(
      Uri.parse('https://amadeus-request-t5wtk4fqgq-ew.a.run.app/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'query': data["text"],
        'date': data["date"],
        'escale': data["escale"],
        'nbPassagers': data["nbPassagers"],
      }),
    );
    if (response.statusCode == 200) {
      return parseTickets(response.body);
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  void amadeusDataTransfer() async {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)?.settings.arguments as Map;

    List<Ticket> body = await fetchTickets(data);
    Navigator.pushNamed(context, '/amadeus', arguments: {
      "body": body,
    });

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
      amadeusDataTransfer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SpinKitWave(
        color: const Color.fromARGB(255, 108, 160, 255),
        size: 90.0,
      )),
    );
  }
}
