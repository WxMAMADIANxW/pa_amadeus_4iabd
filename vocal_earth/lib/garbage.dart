// // ignore_for_file: avoid_print

// import 'package:avatar_glow/avatar_glow.dart';
// import 'package:flutter/material.dart';
// import 'package:highlight_text/highlight_text.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;




// import 'package:flutter/material.dart';
// import 'package:sandbox/pages/home.dart';
// import 'package:sandbox/pages/loading.dart';
// import 'package:sandbox/pages/choose_location.dart';

// void main() => runApp(MaterialApp(
//       initialRoute: "/",
//       routes: {
//         "/": (context) => Loading(),
//         "/home": (context) => Home(),
//         "/location": (context) => ChooseLocation(),
//       },
//     ));
// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'VocalEarth',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const SpeechScreen(),
//     );
//   }
// }

// class SpeechScreen extends StatefulWidget {
//   const SpeechScreen({Key? key}) : super(key: key);

//   @override
//   State<SpeechScreen> createState() => _SpeechScreenState();
// }

// class _SpeechScreenState extends State<SpeechScreen> {
//   final Map<String, HighlightedWord> _highlights = {
//     'paris': HighlightedWord(
//       onTap: () => print('paris'),
//       textStyle: const TextStyle(
//         color: Colors.blue,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//     'marseille': HighlightedWord(
//       onTap: () => print('marseille'),
//       textStyle: const TextStyle(
//         color: Colors.blue,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//     'lyon': HighlightedWord(
//       onTap: () => print('lyon'),
//       textStyle: const TextStyle(
//         color: Colors.blue,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//     'train': HighlightedWord(
//       onTap: () => print('train'),
//       textStyle: const TextStyle(
//         color: Colors.purple,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//   };
//   // ignore: unused_field
//   late stt.SpeechToText _speech;
//   late bool _isListening = false;
//   // ignore: unused_field
//   String _text = "Appuyer sur le bouton pour parler";
//   double _confidence = 1.0;

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Confidence :${(_confidence * 100.0).toStringAsFixed(1)}%'),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: AvatarGlow(
//         endRadius: 75.0,
//         glowColor: Theme.of(context).primaryColor,
//         animate: _isListening,
//         duration: const Duration(milliseconds: 2000),
//         repeatPauseDuration: const Duration(microseconds: 100),
//         repeat: true,
//         child: FloatingActionButton(
//           onPressed: _listen,
//           child: Icon(_isListening ? Icons.mic : Icons.mic_none),
//         ),
//       ),
//       body: SingleChildScrollView(
//         reverse: true,
//         child: Container(
//           padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
//           child: TextHighlight(
//             text: _text,
//             words: _highlights,
//             textStyle: const TextStyle(
//               fontSize: 32.0,
//               color: Colors.black,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

  // void _listen() async {
  //   if (!_isListening) {
  //     bool available = await _speech.initialize(
  //       onStatus: (val) => print('onStatus: $val'),
  //       onError: (val) => print('onError: $val'),
  //     );
  //     if (available) {
  //       setState(() => _isListening = true);
  //       _speech.listen(
  //         onResult: (val) => setState(() {
  //           _text = val.recognizedWords;
  //           if (val.hasConfidenceRating && val.confidence > 0) {
  //             _confidence = val.confidence;
  //           }
  //         }),
  //       );
  //     }
  //   } else {
  //     setState(() => _isListening = false);
  //     _speech.stop();
  //   }
  // }
// }
