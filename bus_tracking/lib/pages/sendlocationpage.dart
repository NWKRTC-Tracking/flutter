import 'dart:convert';
import 'dart:isolate';

import 'package:bus_tracking/pages/background.dart';
import 'package:fl_location/fl_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}



class SendLocationPage extends StatefulWidget {
  const SendLocationPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SendLocationPageState();
}

class _SendLocationPageState extends State<SendLocationPage> {


  ReceivePort? _receivePort;
  int FREQUENCY_SEC = 1;
  
  DateTime lastSentTime = DateTime(0,0,0,0,0);
  double lastLatitude = 0.0;
  double lastLongitude = 0.0;
  int delay = 0;


  // ...

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription: 'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 10,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> _startForegroundTask() async {
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    // You can save data using the saveData function.
    // await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Sending Location',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }

    ReceivePort? receivePort;
    if (reqResult) {  ReceivePort? _receivePort;
      receivePort = await FlutterForegroundTask.receivePort;
    }
 
    return _registerReceivePort(receivePort);
  }

  bool _registerReceivePort(ReceivePort? receivePort) {
    _closeReceivePort();
    print(receivePort);
    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        print("inside recieve");
        print(message);
       
        if(message.containsKey('statusCode') && message['statusCode']==200){
          setState(() {
            print("updateing latitude and all");
            lastSentTime = DateTime.fromMillisecondsSinceEpoch(message['time']);
            lastLatitude = message['latitude'];
            lastLongitude = message['longitude'];
            delay = message['delay'];
          });
        }

        
      });

      return true;
    }

    return false;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

   Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

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
  void initState() {
    super.initState();
    _checkAndRequestPermission();
    _initForegroundTask();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  // A widget that prevents the app from closing when the foreground service is running.
  // This widget must be declared above the [Scaffold] widget.
  return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Send Location'),
          centerTitle: true,
        ),
        body: _buildContentView(),
      ),
    );
  }

  Widget _buildContentView() {
    buttonBuilder(String text, {VoidCallback? onPressed}) {
      return ElevatedButton(
        child: Text(text),
        onPressed: onPressed,
      );
    }

    dataBuilder(String label, String value){
      return Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value )
        ],
      );
    }

    return Column(
      children: [

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buttonBuilder('start', onPressed: _startForegroundTask),
                buttonBuilder('stop', onPressed: _stopForegroundTask),
              ],
            )
        ),
        dataBuilder("Previous Sent Time", lastSentTime.toString()),
        dataBuilder("Previous Sent Longitude", lastLongitude.toString()),
        dataBuilder("Previous Sent Latitude", lastLatitude.toString()),
        dataBuilder("Delay", delay.toString())
        
      ]
    );
  }

}
