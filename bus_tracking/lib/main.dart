import 'dart:async';
import 'dart:io';

import 'package:bus_tracking/pages/home.dart';
import 'package:bus_tracking/pages/location.dart';
import 'package:bus_tracking/pages/sendlocationpage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/": ((context) => Home()),
      "/location": ((context) => Location()),
      "/sendlocation": ((context) => SendLocationPage()),
    },
  ));
}
