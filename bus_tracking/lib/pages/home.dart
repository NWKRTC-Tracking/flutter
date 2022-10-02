// import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  Future sendLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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
      return json.decode(response.body);
    } else {
      print("Exception caught: Failed to get data");
    }
  }

  @override
  void initState() {
    super.initState();
    // _locationController = StreamController();
    Timer.periodic(Duration(seconds: 2), (_) => sendLocation());
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
              label: Text('Location'))
        ],
      ),
    );
  }
}
