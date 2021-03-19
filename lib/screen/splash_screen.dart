import 'package:flutter/material.dart';
import 'package:flutter_udacoding_week3/screen/sign_in.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      home: SignIn(),
      duration: 5000,
      imageSize: 200,
      imageSrc: 'assets/images/splash.png',
      text: "FLUTTER UDACODING",
      textType: TextType.ColorizeAnimationText,
      textStyle: TextStyle(
        fontSize: 35.0,
      ),
      colors: [
        Colors.purple,
        Colors.blue,
        Colors.yellow,
        Colors.red,
      ],
      backgroundColor: Colors.white,
    );
  }
}
