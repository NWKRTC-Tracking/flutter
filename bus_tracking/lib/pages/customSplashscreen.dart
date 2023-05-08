import 'dart:async';
import 'package:bus_tracking/pages/home.dart';
import 'package:flutter/material.dart';

class CustomSplashScreen extends StatefulWidget {
  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF424242)],
        ),
      ),
      child: _isLoading
          ? Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
            ),
            child: Center(
                child: Image.asset(
                  'assets/images/logo.jpg',
                  // height: 100.0,
                ),
              ),
          )
          : HomePage(),
      alignment: _isLoading ? Alignment.center : null,
      curve: _isLoading ? Curves.linear : Curves.fastOutSlowIn,
    );
  }
}
