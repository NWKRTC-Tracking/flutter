import 'package:bus_tracking/services/displayMap.dart';
import 'package:flutter/material.dart';

class Location extends StatefulWidget {
  const Location({Key? key}) : super(key: key);

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[200],
      body: SafeArea(
        child: Column(
          children: const <Widget>[
            displayMap(),
            SizedBox(height: 10),
            Text('Location page')
          ],
        ),
      ),
      
    );
  }
}