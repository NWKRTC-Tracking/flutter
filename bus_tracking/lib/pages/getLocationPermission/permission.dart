import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:fl_location/fl_location.dart';



class getPermission extends StatefulWidget {
  const getPermission({Key? key}) : super(key: key);

  @override
  State<getPermission> createState() => _getPermissionState();
}

class _getPermissionState extends State<getPermission> {


  Future<bool> _checkAndRequestPermission({bool? background}) async {
    if (!await FlLocation.isLocationServicesEnabled) {
        final AndroidIntent intent  = new AndroidIntent(
        action: 'android.settings.LOCATION_SOURCE_SETTINGS',
      );

      await intent.launch();
    }


    var locationPermission = await FlLocation.checkLocationPermission();
    // if (locationPermission == LocationPermission.deniedForever) {
    //   // Cannot request runtime permission because location permission is denied forever.
    //   return false;
    // } else 
    if (locationPermission == LocationPermission.denied || locationPermission == LocationPermission.deniedForever) {
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
  Widget build(BuildContext context) {
      print("came to permission");

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        
         Padding(
           padding: const EdgeInsets.all(10.0),
           child: Column(
             children: [
               Center(
                 child: Text(
                  "Bus tracking collects location data to enable sending your location to passengers of your bus even when the app is closed or not in use.",
                   style: TextStyle(fontSize: 18), 
                ),
               ),
              SizedBox(height: 20),

              Center(
                 child: Text(
                  "Please press agree and select 'allow all the time' to give permission",
                   style: TextStyle(fontSize: 18), 
                ),
               ),

             ],
           ),
         ),
         SizedBox(height: 40,),
         
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.blue[800]),
          onPressed: (){
          print("asking something");
          _checkAndRequestPermission(background: true).then((value){
            print("value is"+value.toString());
            if(value== true){
              print("popping");
              Navigator.of(context).pushReplacementNamed("/login");

            }
          });
        }, 
        child: Text("Agree")
        ) ,
        
      ]),
    );
  }
}