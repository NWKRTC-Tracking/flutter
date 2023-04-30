import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:bus_tracking/main.dart';
import 'package:bus_tracking/models/spinner.dart';
import 'package:bus_tracking/services/displayMap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/url.dart';



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
  String message =""; // the error message sent by server
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
    // Timer.periodic(Duration(seconds: 1), (_) => loadLocation());
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
              // if (snapshot.hasError) {
              //   print("Exception: ${snapshot.error}");
              // }
              // if (snapshot.hasData && message == "") {
              //   // The map is shown with latitude, longitude, delay, bus No
              //   // if we get correct data.
                return Stack(
                  children: [
                    Column(
                      children: <Widget>[
                        displayMap(
                          lat: 14.618316, 
                          long: 74.837834,
                          busNo: widget.busNo,
                          delay : 10, // totalDelay,
                        ),
                      ],

                    ),

                    bottomDetailsSheet(widget.busNo, totalDelay),
                  ],
                );
              // }
              // else if(message != ""){
              //   return Center(
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       children: <Widget>[

              //         Text(message),
              //         ElevatedButton.icon(
              //           style: ElevatedButton.styleFrom(primary: Colors.blueGrey[800]),
              //           onPressed: (){
              //           Navigator.pop(context);
              //         }, 
              //         icon:Icon(
              //           Icons.warning
              //         ), 
              //         label: Text('Return to Home'))
              //       ],
              //     ),
              //   );
              // }
              // else{
              //   // return CustomSpinner;
              //   return CustomSpinnerWithTitle;
              // }
            }),
      ),
    );
  }
}

/// Return the bottom widget with detals of bus and its position.
Widget bottomDetailsSheet(String busNo, int delay) {

  TextStyle whiteBoldTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  ListTile customListTile(String title, String subtitle) {
    return ListTile(
      title: Text(
        title,
        style: whiteBoldTextStyle,
      ),
      subtitle: Text(
        subtitle,
        style: whiteBoldTextStyle,
      ),
    );
  }

  return DraggableScrollableSheet(
    initialChildSize: .2,
    minChildSize: .1,
    maxChildSize: .6,
    builder: (BuildContext context, ScrollController scrollController) {
      return Container(
        color:  Colors.blueGrey[800],
        child: ListView(
          controller: scrollController,
          children: [
            draggableLine(),
            customListTile("Bus Number", busNo),
            customListTile("Delay", delay.toString()),
            customListTile("LIFESPAN", "10"),
            customListTile("WEIGHT", "203"),
          ],
        ),
      );
    },
  );
}

Column draggableLine() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    
    children: [
      Container(
        width: 50,
        height: 4,
        decoration: BoxDecoration(
          border: Border.all(),
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
      )
    ],
  );
}