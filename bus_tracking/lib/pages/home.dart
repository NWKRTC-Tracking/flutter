import 'dart:async';
import 'package:bus_tracking/models/locationData.dart';
import 'package:bus_tracking/pages/location.dart';
import 'package:bus_tracking/services/displayMap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
  _initURIHandler();
  _incomingLinkHandler();
    // _locationController = StreamController();
  }

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
  // @override
  // void initState() {
  // super.initState();
  // // _initURIHandler();
  // // _incomingLinkHandler();
  // }

  @override
  void dispose() {
  _streamSubscription?.cancel();
  super.dispose();
  }

  TextEditingController phoneNoController = TextEditingController();
  TextEditingController busNameController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('HOME'),
        actions: [
          FlatButton.icon(onPressed: (){
            Navigator.pushNamed(context, '/login');
          }, 
          icon: Icon(
            Icons.login
          ), label: Text('Login'))
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Track Bus',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 30),
              )),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: phoneNoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Conductor Mobile No',
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TextField(
              obscureText: true,
              controller: busNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Bus No',
              ),
            ),
          ),
          SizedBox(height: 20,),
          Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                child: const Text('Track'),
                onPressed: () async {
                  var phoneNo = phoneNoController.text.toString();
                  var busNo = busNameController.text.toString();
                  Navigator.pushNamed(context, '/location',arguments: locationData(phoneNo,busNo));
                  // var jwt = await attemptLogIn(username, password);
                  // if(jwt != null) {
                  //   await storage.write(key: "token", value: token);
                  //   await storage.write(key: "jwt", value: jwt);
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => sendLocation(),
                  //     )
                  //   );
                  // } else {
                  //   AlertDialog(semanticLabel: "An Error Occurred No account was found matching that username and password");
                  // }
                },
              )
          )
        ]
      )
    );
  }
}

        