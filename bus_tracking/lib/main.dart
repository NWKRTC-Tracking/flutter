// import 'dart:async';
// import 'dart:io';


import 'package:bus_tracking/pages/home.dart';
import 'package:bus_tracking/pages/location.dart';
import 'package:bus_tracking/pages/sendlocationpage.dart';
import 'package:flutter/foundation.dart';

// import 'package:bus_tracking/pages/home.dart';
// import 'package:bus_tracking/pages/location.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:uni_links/uni_links.dart';


// void main() {
  
//   runApp(MaterialApp(
//     initialRoute: "/",
//     routes: {
//       "/": ((context) => Home()),
//       "/location": ((context) => Location()),
//     },
//   ));
// }

import 'package:bus_tracking/poc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc.dart';
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
      "/": ((context) => Home()),
      "/login" : ((context) => Login()),
      "/location" : ((context) => Location()),
      "/sendlocation": ((context) => SendLocationPage()),
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

// class PocApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     DeepLinkBloc _bloc = DeepLinkBloc();
//     return MaterialApp(
//         title: 'Flutter and Deep Linsk PoC',
//         theme: ThemeData(
//             primarySwatch: Colors.blue,
//             textTheme: TextTheme(
//               subtitle1: const TextStyle(
//                 fontWeight: FontWeight.w300,
//                 color: Colors.blue,
//                 fontSize: 25.0,
//               ),
//             )),
//         home: Scaffold(
//             body: Provider<DeepLinkBloc>(
//                 create: (context) => _bloc,
//                 dispose: (context, bloc) => bloc.dispose(),
//                 child: PocWidget()
//                 )));
//   }
// }
