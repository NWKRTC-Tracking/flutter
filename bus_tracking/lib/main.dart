import 'dart:async';
import 'dart:io';
import 'dart:js';

import 'package:bus_tracking/pages/Login/SignIn.dart';
import 'package:bus_tracking/pages/home.dart';
import 'package:bus_tracking/pages/location.dart';
import 'package:bus_tracking/pages/Login/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';




void main() {
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/" : ((context) => Login()),
      "/home": ((context) => Home()),
      "/signin" : ((context) => SignIn()),
      "/location" : ((context) => Location()),
      
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

