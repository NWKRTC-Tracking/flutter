import 'dart:async';
import 'dart:convert';
import 'package:bus_tracking/services/displayMap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/url.dart';


// final String url = "${getUrl()}api/location/arvind69/";


// final String url = "http://10.196.9.48:8080/api/location/arvind69/";
const String url = "https://api.wheretheiss.at/v1/satellites/25544";


class Location extends StatefulWidget {
  Location({Key? key}) : super(key: key);

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  late StreamController _locationController;
  double lat = 0, long = 0;
  bool _isDisposed = false;

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
    if(_isDisposed) {
      return;
    }
    fetchUser().then((res) async {
      _locationController.add(res);
      setState(() {
        lat = (res['latitude']);
        long = (res['longitude']);
      });
      return res;
    });
  }

  @override
  void initState() {
    super.initState();
    _locationController = StreamController();
    Timer.periodic(Duration(seconds: 1), (_) => loadLocation());
  }

  @override
  void dispose() {
    print("closed");
    _locationController.close();
    super.dispose();
    _isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
                  ],
                ),
              );
            }
            return Text('');
          }),
    );
  }
}
