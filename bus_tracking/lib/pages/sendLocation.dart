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
import 'package:intl/intl.dart';


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
  int? zeroError, startTime;
  

  

  Future<Map> sendLocation(Map data) async {
    int beforeSending =  DateTime.now().millisecondsSinceEpoch;

    print(data);
    var url = '${getUrl()}location';
    //encode Map to JSON
    var body = json.encode(data);

    // data['statusCode'] = 200;
    // data['lastSentTime'] = DateTime.now().millisecondsSinceEpoch;
    
    // try {

    //   print(data);
  
      var response = await http.post(Uri.parse(url),
      headers: {"Content-Type": "application/json", "Authorization":"Bearer $token"}, body: body);
      print("status Code: ${response.statusCode}");
      data['statusCode'] = response.statusCode;

      

      // if (response.statusCode == 200) {
      //   print("response is 200");

      //   data['lastSentTime'] = beforeSending;
      //   data['delay'] =  jsonDecode(response.body)["delay"];
      //   print("status code is 200");
      //   return data;
      // } else {
        
      //   print("Exception caught: Failed to get data");
      //   FlutterForegroundTask.stopService();
      //   return data;
      // }
    // } catch (e) {
    //   print(e); 
    // }

    return data;
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
    
    storage.read(key: "zeroError").then((value) {
      zeroError = int.parse(value!);
    });

     storage.read(key: "startTime").then((value) {
      startTime = int.parse(value!);

    });
    _streamSubscription = FlLocation.getLocationStream().listen((event) async {

      // controllerLat.add(event.latitude);
      print("inside the stream");
      int currentTime =  DateTime.now().millisecondsSinceEpoch;

          
      Map data = {
        'latitude': event.latitude,
        'longitude': event.longitude,
        "start_time": startTime,
        "time": currentTime,
        'key': tripId,
        "zero_error" : zeroError
      };


      
      print(data['time'] - data['start_time' ] + 31159359527 - 1200000 );
      // check if 15 hours have happend, if so delete the trip and stop the foreground service.
      if( data['time'] - data['start_time' ] > 54000000){
        sendPort?.send("15 hours over");
        await FlutterForegroundTask.stopService();
        await storage.delete(key: "tripId");
        await storage.delete(key: "startTime");
        
      }
      FlutterForegroundTask.updateService(
        notificationTitle: 'My Location',
        notificationText: '${event.latitude}, ${event.longitude}',
      );
      data =  await sendLocation(data);

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
  int? lastSentTime, departureTime;
  bool isTripStarted = false, isTripThere = false;
  String? token, phoneNo, jwt, busNo;
  Timer? timer;
  ReceivePort? _receivePort;



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

  
  int FetchFrequency = 5;
  int fetchTripsIn = 5;
  
  void decrementfetchTripsIn(){
    setState(() {
      // decrease timer
       fetchTripsIn--;
    });
  }

  void resetTime(){
    setState(() {
      fetchTripsIn = FetchFrequency;
    });
  }

  
  Future<void> getTrips() async {

    var url = "${getUrl()}generated/$phoneNo";
    var uri = Uri.parse(url);
    print(url);
    print(uri);
    var response = await http.get(
      uri,
      headers: {"Authorization":"Bearer $token"}
      );
    
    print(response.statusCode);
    if(response.statusCode == 200){

      Map tripDetails = jsonDecode(response.body);
      print(tripDetails);
      storage.write(key: "tripId", value: tripDetails['trip_id']);
      storage.write(key: "startTime", value: DateTime.parse(tripDetails['departure_time']).millisecondsSinceEpoch.toString() );

      setState(() {
        isTripThere = true;
        departureTime = DateTime.parse(tripDetails['departure_time']).millisecondsSinceEpoch;
        print(tripDetails['bus_no']);
        busNo = tripDetails['bus_no'];
      });
      timer?.cancel();

    }

  }

  void getTripsTimer(){
    print(fetchTripsIn);
    decrementfetchTripsIn();
    if(fetchTripsIn==0){
        // after the given freq get the trips.
        getTrips();
        resetTime();
        // get trips will set the timer.
      }
  }
      

  bool _registerReceivePort(ReceivePort? receivePort) {
    _closeReceivePort();

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        print('message');
        print(message);

        if(message is Map){
          setState(() {
          lat = message['latitude'];
          long = message['longitude'];
          if(message.containsKey("statusCode") && message['statusCode']== 200)  lastSentTime = DateTime.now().millisecondsSinceEpoch;
          });
        }
        if (message is DateTime) {
          print('timestamp: ${message.toString()}');
        } else if (message is String) {
          if (message == 'onNotificationPressed') {
            Navigator.of(context).pushNamed('/resume-route');
          }
          if(message == "15 hours over"){

            setState(() {
              isTripThere = false;
              isTripStarted = false;
            });
            startgetTripsTimer();
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

  void startgetTripsTimer(){
    storage.read(key: "token").then(((value){
        setState(() {
          token = value;
        });
      }));

      storage.read(key: "jwt").then((value){
        setState(() {
          jwt = value;
        });
        print("jwt");
        print(jwt);
        var jwtspit = jwt!.split(".");
        var payload = json.decode(ascii.decode(base64.decode(base64.normalize(jwtspit[1]))));
        print(payload);
        setState(() {
          phoneNo = payload['sub']; 
        });
      });
      
      
      getTrips();
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) => getTripsTimer());
  }
  

  @override
  void initState() {
    _checkAndRequestPermission();
    super.initState();

   

    storage.read(key: "tripId").then((value){
      if(value != null){
        setState(() {
          isTripThere = true;
        });
      }
    });

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

    if(!isTripThere){
      startgetTripsTimer();
    }

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
    timer?.cancel();
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
    return isTripThere ? buildSendLocation() : buildFetchTrips();
  }

  Widget buildFetchTrips(){
    return Scaffold(
      appBar: AppBar(title: Text("Send Your Location")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
         Center(
           child: Text(
            "You don't have any Trips yet"
                 ),
         ),
        Text("Trips will be fetched agian in $fetchTripsIn seconds"),
        ElevatedButton(onPressed: (){
          setState(() {
            fetchTripsIn = FetchFrequency;
          });
          getTrips();
        }, child: Text("Refresh"))
      ]),
    );
  }

  String  formatTime(int lastSentTime){
      return DateFormat.Hms().format(DateTime.fromMillisecondsSinceEpoch(lastSentTime));  
  }

  Widget buildSendLocation(){
    return WithForegroundTask(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('NWKRTC'),
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
                      isTripStarted ? _stopForegroundTask(): _startForegroundTask();
                
                      setState(() {
                        isTripStarted = !isTripStarted;
                      });
                        _storeTime();
                    },
                   child:  Text(isTripStarted ? "STOP":"START", style: TextStyle(
                    fontSize: 40,
                  ),),
                  style: ElevatedButton.styleFrom(
                  
                    primary: isTripStarted ? Color.fromARGB(255, 252, 111, 101): Color.fromARGB(255, 69, 209, 74),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(80),
                  ),
                  
                  
                    ),),
                  ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  SizedBox(height: 20,),
                  TableRow( label: "Latitude" ,value: lat.toString()),
                  SizedBox(height: 20,),
                  TableRow( label: "Latitude" ,value: long.toString()),
                  SizedBox(height: 20,),
                  TableRow( label: "Last sent time" ,value: lastSentTime == null? "0" :formatTime(lastSentTime!)),
                  SizedBox(height: 20,),
                  TableRow(label: "Bus No", value: busNo.toString()),
                  SizedBox(height: 20,),
                  TableRow(label: "Departure Time", value: departureTime == null ? "0" :formatTime(departureTime!)),
                ],
              ),
            )
            
            
          ],
        ),
      ),
     )
    );
  }
}

class TableRow extends StatelessWidget {
  const TableRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  final String value, label;


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("$label"),
        Text('$value')
        ],
    );
  }
}