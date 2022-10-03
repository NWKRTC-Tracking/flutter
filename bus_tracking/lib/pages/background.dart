
import 'dart:async';
import 'dart:isolate';
import 'package:fl_location/fl_location.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class FirstTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  StreamSubscription<Location>? _streamSubscription;

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

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
      _checkAndRequestPermission();

    _streamSubscription = FlLocation.getLocationStream().listen((event) {
      FlutterForegroundTask.updateService(
        notificationTitle: 'My Location',
        notificationText: '${event.latitude}, ${event.longitude}',
      );

      // Send data to the main isolate.
      sendPort?.send(event);
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
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

