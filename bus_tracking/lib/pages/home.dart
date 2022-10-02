// import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

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
    // _locationController = StreamController();
    Timer.periodic(Duration(milliseconds: 500), (_) => sendLocation());
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
      ),
    );
  }
}
