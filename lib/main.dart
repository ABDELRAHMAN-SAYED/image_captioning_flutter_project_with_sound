import 'package:flutter/material.dart';
import 'package:generatelivecaption/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generate Live Cption',
      home: MySplash(),
      debugShowCheckedModeBanner: false,
    );
  }
}
