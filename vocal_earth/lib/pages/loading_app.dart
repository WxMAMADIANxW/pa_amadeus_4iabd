import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:vocal_earth/pages/screen_query.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Image.asset(
            "assets/vocalearth.gif",
            height: 300,
            width: 300,
          ),
        ],
      ),
      nextScreen: const Query(),
      splashIconSize: 300,
      duration: 2350,
      pageTransitionType: PageTransitionType.rightToLeft,
    );
  }
}
