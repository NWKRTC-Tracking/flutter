import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body:Column(
        children: <Widget>[
          FlatButton.icon(
            onPressed:()async{
              dynamic result = await Navigator.pushNamed(context, "/location");
            }, 
            icon: Icon(
              Icons.location_city
            ), label: Text('Location'))
        ],
      ),
    );
  }
}