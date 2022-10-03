import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uni_links/uni_links.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
bool _initialURILinkHandled = false;




class _HomeState extends State<Home> {
  
  DateTime lastSentTime = DateTime(0,0,0,0,0);
  double lastLatitude = 0.0;
  double lastLongitude = 0.0;

  
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   // Location services are not enabled don't continue
    //   // accessing the position and request users of the 
    //   // App to enable the location services.
    //   return Future.error('Location services are disabled.');
    // }

    permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.denied) {

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  Future sendLocation() async {
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    Position position = await _determinePosition();
    var url = 'http://10.196.9.48:8080/api/location';
    int currentTime =  DateTime.now().millisecondsSinceEpoch;
    print("current real");
    print(currentTime);
    Map data = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      "start_time": currentTime,
      "time": currentTime,
      'key': "arvind69"
    };
    print(data);
    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);
    print("${response.statusCode}");
    print("${response.body}");


    if (response.statusCode == 200) {

      setState(() {


        lastSentTime = DateTime.fromMillisecondsSinceEpoch(currentTime);
        lastLatitude = position.latitude;
        lastLongitude = position.longitude;

      });

      return json.decode(response.body);
    } else {
      print("Exception caught: Failed to get data");
    }
  }

  @override
  void initState() {
    super.initState();
  _initURIHandler();
  _incomingLinkHandler();
    // _locationController = StreamController();
    Timer.periodic(Duration(milliseconds: 500), (_) => sendLocation());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: <Widget>[
          FlatButton.icon(
              onPressed: () async {
                dynamic result =
                    await Navigator.pushNamed(context, "/location");
              },
              icon: Icon(Icons.location_city),
              label: Text('Location')),

              Text("Last sent time = "+lastSentTime.toString()),

              Text("Last Latitude = "+lastLatitude.toString() ),
              Text("Last Longitude ="+lastLongitude.toString())

        ],
      )
    );
  }
}
  // return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Home'),
  //     ),
  //     body: Center(
  //         child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 20),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           // 1
  //           ListTile(
  //             title: const Text("Initial Link"),
  //             subtitle: Text(_initialURI.toString()),
  //           ),
  //           // 2
  //           if (!kIsWeb) ...[
  //             // 3
  //             ListTile(
  //               title: const Text("Current Link Host"),
  //               subtitle: Text('${_currentURI?.host}'),
  //             ),
  //             // 4
  //             ListTile(
  //               title: const Text("Current Link Scheme"),
  //               subtitle: Text('${_currentURI?.scheme}'),
  //             ),
  //             // 5
  //             ListTile(
  //               title: const Text("Current Link"),
  //               subtitle: Text(_currentURI.toString()),
  //             ),
  //             // 6
  //             ListTile(
  //               title: const Text("Current Link Path"),
  //               subtitle: Text('${_currentURI?.path}'),
  //             )
  //           ],
  //           // 7
  //           if (_err != null)
  //             ListTile(
  //               title:
  //                   const Text('Error', style: TextStyle(color: Colors.red)),
  //               subtitle: Text(_err.toString()),
  //             ),
  //           const SizedBox(height: 20,),
  //           const Text("Check the blog for testing instructions")
  //         ],
  //       ),
  //     )));
  // }
// }

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
// }
