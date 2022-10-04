import 'dart:async';
import 'dart:convert';
import 'package:bus_tracking/services/displayMap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final String url = "http://10.196.7.251:8080/api/location/arvind69/";

class Location extends StatefulWidget {
  Location({Key? key}) : super(key: key);

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  late StreamController _locationController;
  double lat = 0, long = 0;

  Future fetchUser() async {
    final response = await http.get(Uri.parse(url));
    print(response.body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Exception caught: Failed to get data");
    }
  }

  loadLocation() async {
    fetchUser().then((res) async {
      _locationController.add(res);
      setState(() {
        // lat = 15.518832 + 0.01 * (res['id'] % 50);
        // long = 74.925252 + 0.01 * (res['id'] % 50);
        print(res);
        lat = (res['latitude']);
        long = (res['longitude']);
      });
      print(lat);
      print(long);
      return res;
    });
  }

  @override
  void initState() {
    super.initState();
    _locationController = StreamController();
    Timer.periodic(Duration(seconds: 2), (_) => loadLocation());
  }

  @override
  void dispose() {
    print("closed");
    _locationController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[200],
      // body: SafeArea(
        // child: Text("location"),
      body: StreamBuilder(
          stream: _locationController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print("Exception: ${snapshot.error}");
            }
            if (snapshot.hasData) {
              // print('lat');
              // print(lat);
              return SafeArea(
                child: Column(
                  children: <Widget>[
                    displayMap(
                      lat: lat,
                      long: long,
                    ),
                    SizedBox(height: 10),
                    // Text(lat as String)
                  ],
                ),
              );
            }
            return Text('Loading');
          }),
    );
  }
}
