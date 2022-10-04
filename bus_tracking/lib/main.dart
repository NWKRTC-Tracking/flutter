import 'dart:async';
import 'dart:io';
import 'dart:js';


import 'package:bus_tracking/pages/home.dart';
import 'package:bus_tracking/pages/location.dart';
import 'package:bus_tracking/pages/Login/login.dart';
import 'package:bus_tracking/pages/sendLocation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';


final storage = FlutterSecureStorage();

void main() {
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/login" : ((context) => Login()),
      "/": ((context) => Home()),
      "/location" : ((context) => Location()),
      "/sendLocation" :((context) => sendLocationCheck()),
    },
    onUnknownRoute: (RouteSettings settings) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) =>
            const Scaffold(body: Center(child: Text('Page Not Found'))),
      );
    },
  ));
}

