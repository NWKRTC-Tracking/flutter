// import 'dart:ui';

import 'package:bus_tracking/pages/home.dart';
import 'package:bus_tracking/pages/location.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/" : ((context) => Home()),
      "/location" : ((context) => Location()),
    },
  ));
}

