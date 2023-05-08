import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:bus_tracking/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class splashScreen extends StatelessWidget {
  const splashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: AnimatedSplashScreen(
          splash: Icons.bus_alert, 
          duration: 5000,
          splashTransition: SplashTransition.fadeTransition,          
          nextScreen: HomePage(),
          backgroundColor: Colors.blue,
        ),
      ) 
    );

    // return MaterialApp(

    //     title: 'Clean Code',
    //     home: AnimatedSplashScreen(
    //         duration: 3000,
    //         splash: Icons.home,
    //         nextScreen: HomePage(),
    //         splashTransition: SplashTransition.fadeTransition,
    //         // pageTransitionType: PageTransitionType.scale,
    //         backgroundColor: Colors.blue));
  }
}