import 'dart:async';
import 'dart:convert';
import 'package:bus_tracking/services/displayMap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


final String url = "https://www.google.com/";

class Location extends StatefulWidget {
  const Location({Key? key}) : super(key: key);

  @override
  State<Location> createState() => _LocationState();

  
}

class _LocationState extends State<Location> {
  late StreamController _locationController;

  Future fetchUser() async{
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      return json.decode(response.body);
    }else{
      print("Exception caught: Failed to get data");
    }
  }

  loadLocation() async{
    fetchUser().then((res) async{
      _locationController.add(res);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text('Bus Location'),
      ),
      backgroundColor: Colors.amber[200],
      body: StreamBuilder(
        stream: _locationController.stream,
        builder: (context, snapshot){ 
          if(snapshot.hasError){
            print("Exception: ${snapshot.error}");
          }
          if(snapshot.hasData){
            return SafeArea(
              child: Column(
                children: const <Widget>[
                  displayMap(),
                  SizedBox(height: 10),
                  Text('Location page')
                ],
              ),
            );
          }
          return Text('Loading');
        }
        ),     
    );
  }
}