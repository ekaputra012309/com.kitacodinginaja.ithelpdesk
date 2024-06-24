import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import '../screens/auth/login.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: Colors.white,
      onInit: () {
        debugPrint("On Init");
      },
      onEnd: () {
        debugPrint("On End");
      },
      childWidget: SizedBox(
        height: 200,
        width: 200,
        child: Image.asset("assets/splash_image.png"),
      ),
      onAnimationEnd: () => debugPrint("On Fade In End"),
      nextScreen: const LoginPage(),
    );
  }
}
