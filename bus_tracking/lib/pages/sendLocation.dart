import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:bus_tracking/main.dart';
import 'package:fl_location/fl_location.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;
import 'package:bus_tracking/config/url.dart';


@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

// double latitude = 0.0, longitude = 0.0;
// StreamController<double> controllerLat = StreamController<double>();

// StreamController<double> controllerLong  = StreamController<double>();

class FirstTaskHandler extends TaskHandler {

  StreamSubscription<Location>? _streamSubscription;
  String? token, tripId, jwt;
  int? zeroError;

  Future<Map> sendLocation(Map data) async {
    int beforeSending =  DateTime.now().millisecondsSinceEpoch;

    var url = '${getUrl()}api/location';
    //encode Map to JSON
    var body = json.encode(data);

    var response = await Future.delayed(Duration(seconds: 1));

    data['statusCode'] = 200;
    data['lastSentTime'] = DateTime.now().millisecondsSinceEpoch;

    return data;

    // var response = await http.post(Uri.parse(url),
    //     headers: {"Content-Type": "application/json", "Authorization":"Bearer $token"}, body: body);
    // print("${response.statusCode}");

    // print(response.body.runtimeType);

    // if (response.statusCode == 200) {
    //   data['statusCode'] = response.statusCode;
    //   data['delay'] =  DateTime.now().millisecondsSinceEpoch+ -beforeSending;
    //   print("status code is 200");
    //   return data;
    // } else {
      
    //   print("Exception caught: Failed to get data");
    //   FlutterForegroundTask.stopService();
    //   return data;
    // }


    
  }

 

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {

   

    storage.read(key: "jwt").then((value) {
      jwt = value;
    });
    storage.read(key: "tripId").then((value) {
      tripId = value;
    });
    storage.read(key: "token").then((value){
      token = value;
    });
    storage.read(key: "zero_error").then((value) {
      zeroError = int.parse(value!);
    });

    _streamSubscription = FlLocation.getLocationStream().listen((event) async {

      // controllerLat.add(event.latitude);
      print("inside the stream");
      int currentTime =  DateTime.now().millisecondsSinceEpoch;
      
      Map data = {
        'latitude': event.latitude,
        'longitude': event.longitude,
        "start_time": currentTime,
        "time": currentTime,
        'key': tripId,
        "zero_error" : zeroError
      };
      data =  await sendLocation(data);

      FlutterForegroundTask.updateService(
        notificationTitle: 'My Location',
        notificationText: '${event.latitude}, ${event.longitude}',
      );

      // Send data to the main isolate.
      // print(event);
      sendPort?.send(data);
    });
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    print("on event");


  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await _streamSubscription?.cancel();
  }
  SendPort? _sendPort;

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


class sendLocation extends StatefulWidget {
  const sendLocation({Key? key}) : super(key: key);

  @override
  State<sendLocation> createState() => _sendLocationState();
}

class _sendLocationState extends State<sendLocation> {

  // late StreamSubscription<double> streamLat;

  double lat = 0, long = 0;
  bool isTripStarted = false;


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
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  ReceivePort? _receivePort;

  // ...
  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  Future<bool> _startForegroundTask() async {

    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }

    ReceivePort? receivePort;
    if (reqResult) {
      receivePort = await FlutterForegroundTask.receivePort;
    }
 
    return _registerReceivePort(receivePort);
  }

  bool _registerReceivePort(ReceivePort? receivePort) {
    _closeReceivePort();

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        print('message');
        print(message);
        setState(() {
          lat = message['latitude'];
          long = message['longitude'];
        });
        if (message is DateTime) {
          print('timestamp: ${message.toString()}');
        } else if (message is String) {
          if (message == 'onNotificationPressed') {
            Navigator.of(context).pushNamed('/resume-route');
          }
        }
      });

      return true;
    }
    print('no recieve port');
    return false;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  @override
  void initState() {
    _checkAndRequestPermission();
    super.initState();

    storage.write(key: "tripId", value: "d99b9824f405f1385c23907d70192d5cc57bce60");
    storage.write(key: "zeroError",value: "1234");
    storage.write(key: "startTime", value: "1664948125000");

    _initForegroundTask();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        setState(() {
          isTripStarted = true;
        });
        _startForegroundTask();
        print('flutter foreground atsk');
        final newReceivePort = await FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
    // Stream stream = controllerLat.stream;
      // streamLat = controllerLat.stream.listen((event) {
      //     print('listener');
      //   print(event);
      // });
  }


    void _storeTime()async{
      // print('store time function');
    if(isTripStarted){
      var curTime = DateTime.now().millisecondsSinceEpoch;
      await storage.write(key: 'timeStamp',value: curTime.toString());
    }
    
    }



  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
    // streamLat.cancel();
  }

  late Stream stream;
  // double lat  = 0 , long = 0;
  // StreamSubscription<double>? _streamSubscriptionLoc;
  // Stream stream = controllerLat.stream;
  
  // stream.listen((value){
  //   print(value);
  // })

    
  

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(

      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueGrey[800],
            title: Text('NWKRTC'),
            centerTitle: true,
            actions: [
              FlatButton.icon(onPressed: (){
                storage.deleteAll();
                Navigator.pushReplacementNamed(context, '/');
              }, 
              icon: Icon(Icons.logout,color: Colors.white,
              ), 
              label: Text('logout',style: TextStyle(color: Colors.white),))
            ],
          ),
          body: Column(
      
            children: <Widget>[
              Expanded(
                child: Center(
                  child: ElevatedButton(onPressed:(){
                      // print('time stamp storing');
                      
      
                      isTripStarted ? _stopForegroundTask(): _startForegroundTask();
                
                      setState(() {
                        isTripStarted = !isTripStarted;
                      });
                      _storeTime();
                    }
                  , child:  Text(isTripStarted ? "Stop":"Start", style: TextStyle(
                    fontSize: 20,
                
                
                  ),),
                  style: ElevatedButton.styleFrom(
                  
                    primary: isTripStarted ? Color.fromARGB(255, 252, 111, 101): Color.fromARGB(255, 69, 209, 74),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(50),
                  ),
                  
                  ),
                ),
              ),
      
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    SizedBox(height: 20,),
                    Text('$lat'),
                    SizedBox(height: 20,),
                    Text('$long'),
                  ],
                ),
              )
              
              
            ],
          ),
        ),
      ),
    );
  }
}