
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:bus_tracking/config/url.dart';
import 'package:fl_location/fl_location.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;

class FirstTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  StreamSubscription<Location>? _streamSubscription;
  Map sentData = {
    "latitude": 0.0,
    "longitude": 0.0,
    "time": 0
  };

  Future<bool> _checkAndRequestPermission({bool? background}) async {
    if (!await FlLocation.isLocationServicesEnabled) {
      // Location services are disabled.
      return false;
    }

    var locationPermission = await FlLocation.checkLocationPermission();
    if (locationPermission == LocationPermission.deniedForever) {
      // Cannot request runtime permission because location permission is denied forever.
      return false;
    } else if (locationPermission == LocationPermission.denied) {
      // Ask the user for location permission.
      locationPermission = await FlLocation.requestLocationPermission();
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever) return false;
    }

    // Location permission must always be allowed (LocationPermission.always)
    // to collect location data in the background.
    if (background == true &&
        locationPermission == LocationPermission.whileInUse) return false;

    // Location services has been enabled and permission have been granted.
    return true;
  }

  Future<Map> sendLocation(Map data) async {
    int beforeSending =  DateTime.now().millisecondsSinceEpoch;

    var url = '${getUrl()}api/location';
    //encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);
    print("${response.statusCode}");

    print(response.body.runtimeType);

    if (response.statusCode == 200) {
      data['statusCode'] = response.statusCode;
      data['delay'] =  DateTime.now().millisecondsSinceEpoch+ -beforeSending;
      print("status code is 200");
      return data;
    } else {
      
      print("Exception caught: Failed to get data");
      return data;

    }
  }



  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
      _checkAndRequestPermission();

    _streamSubscription = FlLocation.getLocationStream().listen((event) async {
     
      int currentTime =  DateTime.now().millisecondsSinceEpoch;
      Map data = {
        'latitude': event.latitude,
        'longitude': event.longitude,
        "start_time": currentTime,
        "time": currentTime,
        'key': "arvind69"
      };
      
      data =  await sendLocation(data);

      print(data);
      
      FlutterForegroundTask.updateService(
        notificationTitle: 'My Location',
        notificationText: '${event.latitude}, ${event.longitude}',
      );
      sendPort?.send(data);
    });
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await _streamSubscription?.cancel();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a event through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

