import 'package:flutter/material.dart';

class Offline extends StatelessWidget {
  const Offline({
    Key? key,
    required this.isOffline,
  }) : super(key: key);

  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return isOffline?  Container(
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(isOffline ? "You are offline": ""),
      ),
    ): Text("") ;
  }
}