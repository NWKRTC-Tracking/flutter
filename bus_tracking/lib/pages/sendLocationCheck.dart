import 'dart:async';
import 'dart:convert';

import 'package:bus_tracking/main.dart';
import 'package:bus_tracking/pages/Login/login.dart';
import 'package:bus_tracking/pages/sendLocation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../config/url.dart';

Future<String?> attemptLogIn(String phoneNo, String password) async {
    final msg = jsonEncode({"phoneNo":phoneNo,"password":password,});
    Map<String,String> headers = {'Content-Type':'application/json'};
    var response = await post(
      Uri.parse('${getUrl()}login/'),
      headers: headers,
      body: msg,
    );
    

    if(response.statusCode == 200){ 
      return response.body;
    }

    return null;
  }

class sendLocationCheck extends StatelessWidget {

  String username= "", password  = "";


   Future<String> get jwtOrEmpty async {
    username = "8660925038";
    password = "mypassword";
    // REMOVE HERE
    var jwt = await attemptLogIn(username, password);
    var token = jsonDecode(jwt!)['token'].toString();
    await storage.write(key: "token", value: token);
    await storage.write(key: "jwt", value: jwt);
    // TO HERE
    jwt = await storage.read(key: "jwt"); // removed var from here.
    if(jwt == null) return "";
    return jwt;
  }


  sendLocationCheck({Key? key}) : super(key: key); // removed const from constructor.
 
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