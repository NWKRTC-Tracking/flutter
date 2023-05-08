import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:bus_tracking/main.dart';
import 'package:bus_tracking/models/offline.dart';
import 'package:bus_tracking/models/spinner.dart';
import 'package:fl_location/fl_location.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/src/foundation/key.dart';
// import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:http/http.dart' as http;
import 'package:bus_tracking/config/url.dart';
import 'package:intl/intl.dart';
import 'package:android_intent_plus/android_intent.dart';


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
  

  

  Future<Map> sendLocation(Map data , SendPort? sendPort) async {
    int beforeSending =  DateTime.now().millisecondsSinceEpoch;

    print(data);
    var url = '${getUrl()}location';
    //encode Map to JSON
    var body = json.encode(data);

    // data['statusCode'] = 200;
    // data['lastSentTime'] = DateTime.now().millisecondsSinceEpoch;
    
    // try {

    //   print(data);
      try {
          var response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json", "Authorization":"Bearer $token"}, body: body);
          print("status Code: ${response.statusCode}");
          data['statusCode'] = response.statusCode;
      }
      on SocketException catch (e){
        sendPort?.send(e.runtimeType);
        print("Socket exception");
        data['Exception'] = e.runtimeType.toString();
        
      }
      catch (e){
        print("general exception");
        print(e);
      }
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
    _streamSubscription = FlLocation.getLocationStream(interval: 20000).listen((event) async {
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
        
        await storage.delete(key: "tripId");
        await storage.delete(key: "startTime");
        await storage.delete(key: "lastSentTime");
        await FlutterForegroundTask.stopService();
      }
      FlutterForegroundTask.updateService(
        notificationTitle: 'My Location',
        notificationText: '${event.latitude}, ${event.longitude}',
      );
      data =  await sendLocation(data, sendPort);

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
  bool isTripStarted = false, isTripThere = false, isFetching = false, isOffline = false;
  String? token, phoneNo, jwt, busNo;
  Timer? timer;
  ReceivePort? _receivePort;




   Future<bool> _checkAndRequestPermission({bool? background}) async {
    if (!await FlLocation.isLocationServicesEnabled) {
        final AndroidIntent intent  = new AndroidIntent(
        action: 'android.settings.LOCATION_SOURCE_SETTINGS',
      );

      await intent.launch();
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

    await _checkAndRequestPermission();

    if(!await FlLocation.isLocationServicesEnabled){
      return false;
    }


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

  
  int FetchFrequency = 20;
  int fetchTripsIn = 2;
  
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
      storage.write(key: "startTime", value: (DateTime.parse(tripDetails['departure_time']).millisecondsSinceEpoch + 19800000).toString() );

      setState(() {
        isTripThere = true;
        //GMT to IST Conversion
        departureTime = DateTime.parse(tripDetails['departure_time']).millisecondsSinceEpoch + 19800000;
        print(tripDetails['bus_no']);
        busNo = tripDetails['bus_no'];
        storage.write(key: "busNo", value: busNo);
        storage.write(key: "departureTime", value: departureTime.toString());
      });
      timer?.cancel();

    }
    else if(response.statusCode == 404){
      
      if(isTripStarted == true){
        _stopForegroundTask();
      }
       
      setState(() {
        isTripThere = false;
        isTripStarted = false;
      });    
      
      storage.delete(key: "tripId");
      storage.delete(key: "lastSentTime");
      storage.delete(key: "departureTime");

    }
    setState(() {
      isFetching = false;
    });

  }

  void getTripsTimer(){
    print(fetchTripsIn);
    decrementfetchTripsIn();
    if(fetchTripsIn==0){
        setState(() {
          isFetching = true;
        });
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

          if(message['statusCode'] == 200){
            setState(() {
              isOffline = false;
              lastSentTime = DateTime.now().millisecondsSinceEpoch;
            });
          }
          if(message['statusCode']== 404){

            _stopForegroundTask();
            setState(() {
              isTripThere = false;
              isTripStarted = false;
            });
            
            storage.delete(key: "tripId");
            storage.delete(key: "lastSentTime");
            storage.delete(key: "departureTime");
            startgetTripsTimer();
          }
        }
        else if (message is DateTime) {
          print('timestamp: ${message.toString()}');
        } 
        else if (message is String) {
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
          if(message == "Trip is deleted"){
            print("trip is deleted");
            setState(() {
              isTripThere = false;
              isTripStarted = false;
              
            });
            startgetTripsTimer();
          }

        }
        else if(message is Type){
          if(message.toString() == '_ClientSocketException'){
            setState(() {
              isOffline = true;
            });
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
      print("started get Trips timer");
      
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
    storage.read(key: "busNo").then((value) {
      if(value != null){
        setState(() {
          busNo = value;
        });
      }
    },);
    storage.read(key: "departureTime").then((value){
      if(value!=null){
        setState(() {
        departureTime = int.parse(value);
      });
      }
    });

    storage.read(key: "lastSentTime").then((value){
      if(value!= null){
        setState(() {
          lastSentTime = int.parse(value);
        });
      }
    });

    _initForegroundTask();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
    return isFetching? CustomSpinnerWithTitle :Scaffold(
      appBar: AppBar(
      title: Text("NWKRTC"),
      actions: [
                FloatingActionButton.extended(onPressed: (){
                  storage.deleteAll();
                  timer?.cancel();
                  Navigator.pushReplacementNamed(context, '/');
                }, 
                icon: Icon(Icons.logout,color: Colors.white,
                ), 
                label: Text('logout',style: TextStyle(color: Colors.white),))
            ],
      backgroundColor: Colors.blueGrey[800],
      
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
         Center(
           child: Text(
            "You don't have any Trips yet",
             style: TextStyle(fontSize: 18), 
          ),
         ),
         SizedBox(height: 40,),
         Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Text("Fetching agian in " , style: TextStyle(fontSize: 18), ),
          Text("$fetchTripsIn", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          Text(" seconds",  style: TextStyle(fontSize: 18), ),
          ],
         ),
         SizedBox(height: 40,),
        ElevatedButton(onPressed: (){
          setState(() {
            fetchTripsIn = FetchFrequency;
            isFetching = true;
          });
          getTrips();
        }, 
        child: Icon(
          
          Icons.refresh_rounded,
          size: 40,
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue[800],
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),

        ),
        ) ,
        
      ]),
    );
  }

  String  formatTime(int dateTime){
      return DateFormat("hh:mm:ss a").format(DateTime.fromMillisecondsSinceEpoch(dateTime));  
  }
  String formatDate(int dateTime){
    return DateFormat("dd-MM-yyyy").format(DateTime.fromMillisecondsSinceEpoch(dateTime));
  }

  Widget buildSendLocation(){
    return WithForegroundTask(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueGrey[800],
            title: Text('NWKRTC'),
            actions: [
                FloatingActionButton.extended(onPressed: (){
                  _stopForegroundTask();
                  storage.deleteAll();
                  Navigator.pushReplacementNamed(context, '/');
                }, 
                // backgroundColor: Colors.blueGrey[900],
                icon: Icon(Icons.logout,color: Colors.white,
                ), 
                label: Text('logout',style: TextStyle(color: Colors.white),))
              ],
          ),
          body: Column(
      
            children: <Widget>[
              Offline(isOffline: isOffline),
              Expanded(
                child: Center(
                  child: ElevatedButton(onPressed:(){
                      // isTripStarted ? _stopForegroundTask(): _startForegroundTask();

                      if(isTripStarted){
                        _stopForegroundTask();
                        setState(() {
                          isTripStarted = !isTripStarted;
                        });
                      }
                      else{
                        _startForegroundTask().then((value){
                            if(value){
                              setState(() {
                                isTripStarted = !isTripStarted;
                              });
                            }
                            
                        });
                      }
                
                      _storeTime();
                    },
                   child:  Text(isTripStarted ? "STOP":"START", style: TextStyle(
                    fontSize: 40,
                  ),),

                  style: ElevatedButton.styleFrom(
                    side: BorderSide(width: 10, color: isTripStarted ? Color.fromARGB(255, 252, 111, 101): Color.fromARGB(255, 69, 209, 74)),
                    // primary: Color.fromRGBO(0, 0, 0, 0.01),
                    primary: Color.fromRGBO(255, 255, 255, 0.5),
                    // shadowColor: isTripStarted ? Color.fromARGB(255, 252, 111, 101): Color.fromARGB(255, 69, 209, 74),
                    onPrimary: Colors.black,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(80),
                  ),
                  
                  
                    ),),
                  ),
            Expanded(
              child: ListView(children: <Widget>[  
            Center(
                child: Text(  
                  'Previous Sent data',  
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),  
                )),  
            DataTable(  
              columns: [
                DataColumn(label: Text(  
                    '',  
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)  
                )),  
                DataColumn(label: Text(  
                    '',  
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)  
                )),    
              ],
              rows: [  
                datarow("Bus No", busNo.toString()),
                datarow("Departure Date", departureTime == null ? "-": formatDate(departureTime!) ),
                datarow("Departure Time",departureTime == null ? "-" :formatTime(departureTime!)),
                datarow( "Last sent time" ,lastSentTime == null? "-" :formatTime(lastSentTime!)),
              ],  
            ),  
          ])  ,
            )
            
            
          ],
        ),
      ),
     )
    );
  }

  DataRow datarow(String label,String value) {
    return DataRow(cells: [  
                DataCell(Text(
                  label,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)  
                  )),
                DataCell(Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)  
                )),   
              ]);
  }
}

