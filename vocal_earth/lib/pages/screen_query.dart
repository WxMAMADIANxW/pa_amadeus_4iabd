import 'package:flutter/material.dart';

class Query extends StatefulWidget {
  const Query({Key? key}) : super(key: key);

  @override
  State<Query> createState() => _QueryState();
}

class _QueryState extends State<Query> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('VocalEarth'),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 108, 160, 255),
        ),
        body: Center(
          child: SizedBox(
              height: 200,
              width: 200,
              child: FloatingActionButton(
                  backgroundColor: Color.fromARGB(255, 108, 160, 255),
                  onPressed: () {},
                  child: const Icon(
                    Icons.flight_takeoff,
                    color: Colors.white,
                    size: 90,
                  ))),
        ));
  }
}
