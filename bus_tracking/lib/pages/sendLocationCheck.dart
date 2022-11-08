import 'dart:async';
import 'dart:convert';

import 'package:bus_tracking/main.dart';
import 'package:bus_tracking/pages/Login/login.dart';
import 'package:bus_tracking/pages/sendLocation.dart';
import 'package:flutter/material.dart';

class sendLocationCheck extends StatelessWidget {

   Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if(jwt == null) return "";
    return jwt;
  }


  const sendLocationCheck({Key? key}) : super(key: key);
 
  // static const String _title = 'NWKRTC';
 
  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
          // appBar: AppBar(
          //   title: const Text(_title),
          // ),
          body: FutureBuilder(
          future: jwtOrEmpty,            
          builder: (context, snapshot) {
            if(!snapshot.hasData) return LoginWidget();
            if(snapshot.data != "") {
              var str = snapshot.data.toString();
              var jwt = str.split(".");
              print(jwt.length);
              if(jwt.length !=3) {
                return LoginWidget();
              } else {
                var payload = json.decode(ascii.decode(base64.decode(base64.normalize(jwt[1]))));
                if(DateTime.fromMillisecondsSinceEpoch(payload["exp"]*1000).isAfter(DateTime.now())) {
                  return sendLocation();
                } else {
                  return LoginWidget();
                }
              }
            } else {
              return LoginWidget();
            }
          }
        ),
        ),
    );
  }
}