import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:vocal_earth/pages/loading_app.dart';
import 'package:vocal_earth/pages/screen_date.dart';
import 'package:vocal_earth/pages/screen_escale.dart';
import 'package:vocal_earth/pages/screen_nbpassenger.dart';
import 'package:vocal_earth/pages/screen_query.dart';

void main() => runApp(MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen(),
        "/query": (context) => const Query(),
      },
    ));
