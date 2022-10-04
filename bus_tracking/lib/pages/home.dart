import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uni_links/uni_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
bool _initialURILinkHandled = false;




class _HomeState extends State<Home> {

  Uri? _initialURI;
  Uri? _currentURI;
  Object? _err;
  StreamSubscription? _streamSubscription;
  void _incomingLinkHandler() {
  // 1
  if (!kIsWeb) {
    // 2
    _streamSubscription = uriLinkStream.listen((Uri? uri) {
      if (!mounted) {
        return;
      }
      debugPrint('Received URI: $uri');
      setState(() {
        _currentURI = uri;
        _err = null;
      });
      // 3
    }, onError: (Object err) {
      if (!mounted) {
        return;
      }
      debugPrint('Error occurred: $err');
      setState(() {
        _currentURI = null;
        if (err is FormatException) {
          _err = err;
        } else {
          _err = null;
        }
      });
    });
  }
  }

  Future<void> _initURIHandler() async {
 // 1
  if (!_initialURILinkHandled) {
    _initialURILinkHandled = true;
    // 2
    Fluttertoast.showToast(
        msg: "Invoked _initURIHandler",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white
    );
    try {
      // 3
      final initialURI = await getInitialUri();
      // 4
      if (initialURI != null) {
        debugPrint("Initial URI received $initialURI");
        if (!mounted) {
          return;
        }
        setState(() {
          _initialURI = initialURI;
        });
      } else {
        debugPrint("Null Initial URI received");
      }
    } on PlatformException { // 5
      debugPrint("Failed to receive initial uri");
    } on FormatException catch (err) { // 6
      if (!mounted) {
        return;
      }
      debugPrint('Malformed Initial URI received');
      setState(() => _err = err);
    }
  }
  }
  @override
  void initState() {
  super.initState();
  _initURIHandler();
  _incomingLinkHandler();
  }

  @override
  void dispose() {
  _streamSubscription?.cancel();
  super.dispose();
  }


  @override
  Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          FlatButton.icon(onPressed: (){
            // Navigator.push(context, '/login');
            Navigator.pushNamed(context, '/login');
          }, 
          icon: Icon(
            Icons.login
          ), label: Text('Login'))
        ],
      ),
      body: const Center(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('Home'),
      )));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.grey[200],
  //     body:Column(
  //       children: <Widget>[
  //         FlatButton.icon(
  //           onPressed:()async{
  //             dynamic result = await Navigator.pushNamed(context, "/location");
  //           }, 
  //           icon: Icon(
  //             Icons.location_city
  //           ), label: Text('Location'))
  //       ],
  //     ),
  //   );
  // }
}