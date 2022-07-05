import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:generatelivecaption/home.dart';

// import 'package:flutter_native_splash/flutter_native_splash.dart';
class MySplash extends StatefulWidget {
  // const MySplash({Key? key}) : super(key: key);

  @override
  State<MySplash> createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: Home(),
      title: Text(
        'Text Generator',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),
      ),
      image: Image.asset('assets/notepad.png'),
      gradientBackground: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.004, 1],
          colors: [Color(0x11232526), Color(0xFF232526)]),
      photoSize: 50,
      loaderColor: Colors.white,
    );
  }
}
