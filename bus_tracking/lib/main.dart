
import 'package:bus_tracking/models/locationKey.dart';
import 'package:bus_tracking/pages/home.dart';
import 'package:bus_tracking/pages/location.dart';
import 'package:bus_tracking/pages/resumepage.dart';
// import 'package:bus_tracking/pages/sendlocationpage.dart';
import 'package:flutter/foundation.dart';
import 'package:bus_tracking/poc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc.dart';
import 'package:bus_tracking/pages/Login/login.dart';
import 'package:bus_tracking/pages/sendLocationCheck.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';


final storage = FlutterSecureStorage();

void main() {

  //Deleting all keys in storage based on inactivity
  var curTime = DateTime.now().millisecondsSinceEpoch;
  storage.read(key: 'timeStamp').then((value){
    if(value != ""){
      var prev = DateTime.fromMillisecondsSinceEpoch(int.parse(value!));
      var cur = DateTime.fromMillisecondsSinceEpoch(curTime);
      DateTime dt1 = DateTime.parse(cur.toString());
      DateTime dt2 = DateTime.parse(prev.toString());
      Duration diff = dt1.difference(dt2);
      if(diff.inHours > 5){
        storage.deleteAll();
        storage.write(key: 'timeStamp',value: curTime.toString());
      }
    }
    storage.write(key: 'timeStamp',value: curTime.toString());
  });
  
  
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/": ((context) => Home()),
      "/login" : ((context) => Login()),
      "/sendlocation": ((context) => sendLocationCheck()),
      '/resume-route': (context) => const ResumeRoutePage(),
    },
    onGenerateRoute: (settings) {
          if (settings.name == Location.routeName) {
            locationKey? args = (settings.arguments?? locationKey("")) as locationKey?;
            if(args!.key == ""){
              print('apikey null in main');
              return MaterialPageRoute(builder: (context){
                Navigator.pushReplacementNamed(context, '/');
                return Text('Home');
              });
            }
            return MaterialPageRoute(
              builder: (context) {
                return Location(
                  apiKey: args!.key,
                );
              },
            );
          }
          assert(false, 'Implementation ${settings.name}');
          return null;
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
