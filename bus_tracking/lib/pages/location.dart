import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:bus_tracking/main.dart';
import 'package:bus_tracking/models/spinner.dart';
import 'package:bus_tracking/services/displayMap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/url.dart';


// final String url = "${getUrl()}api/location/arvind69/";


// final String url = "http://10.196.9.48:8080/api/location/";
String url = getUrl() + "location/";


class Location extends StatefulWidget {
  static const routeName = '/location';

  String apiKey;
  String busNo;
  Location({Key? key, required this.apiKey, required this.busNo}) : super(key: key);

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {



  late StreamController _locationController;
  double lat = 0, long = 0;
  int conductor_delay = 0, server_delay = 0, delay = 0, totalDelay = 0;
  String message ="";
  bool _isDisposed = false;
  late String token;

  Future fetchUser() async {
    final response = await http.get(Uri.parse(url+widget.apiKey));
    if (response.statusCode == 200) {
      setState(() {
        message = "";
      });
      return json.decode(response.body);
    } else {
      setState(() {
        message = json.decode(response.body)['message'];
      });
      print("Exception caught: Failed to get data");
    }
    return null;
  }

  loadLocation() async {
    if(_isDisposed) {
      return;
    }
    var startTime = DateTime.now().millisecondsSinceEpoch;
    fetchUser().then((res) async {
      if(res != null){
        _locationController.add(res);
        var endTime = DateTime.now().millisecondsSinceEpoch;
        var prev = DateTime.fromMillisecondsSinceEpoch(startTime);
        var cur = DateTime.fromMillisecondsSinceEpoch(endTime);
        DateTime dt1 = DateTime.parse(cur.toString());
        DateTime dt2 = DateTime.parse(prev.toString());
        Duration diff = dt1.difference(dt2);
        
        setState(() {
          lat = (res['latitude']);
          long = (res['longitude']);
          conductor_delay = res['conductor_delay'];
          server_delay = res['server_delay'];
          delay = diff.inMilliseconds;
        });
        var total =( delay + conductor_delay.toInt() + server_delay.toInt())/1000;
        setState(() {
          totalDelay = total.toInt();
        });
        return res;   
      }
        
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
    _locationController.close();
    super.dispose();
    _isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: StreamBuilder(
            stream: _locationController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print("Exception: ${snapshot.error}");
              }
              if (snapshot.hasData && message == "") {
                // print('lat');
                // print(lat);
                return Column(
                  children: <Widget>[
                    displayMap(
                      lat: lat,
                      long: long,
                      busNo: widget.busNo,
                      delay : totalDelay
                    ),
                  ],
                );
              }
              else if(message != ""){
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Text(message),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(primary: Colors.blueGrey[800]),
                        onPressed: (){
                        Navigator.pop(context);
                      }, 
                      icon:Icon(
                        Icons.warning
                      ), 
                      label: Text('Return to Home'))
                    ],
                  ),
                );
              }
              else{
                return CustomSpinner;
              }
            }),
      ),
    );
  }
}
