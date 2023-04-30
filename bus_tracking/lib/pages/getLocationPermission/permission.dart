import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:fl_location/fl_location.dart';
import 'package:app_settings/app_settings.dart';



class getPermission extends StatefulWidget {
  const getPermission({Key? key}) : super(key: key);

  @override
  State<getPermission> createState() => _getPermissionState();
}

class _getPermissionState extends State<getPermission> {


  Future<bool> _checkAndRequestPermission({bool? background}) async {
    // // if (!await FlLocation.isLocationServicesEnabled) {
    //     final AndroidIntent intent  = new AndroidIntent(
    //     action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    //   );

    //   await intent.launch();
    // // }


    var locationPermission = await FlLocation.checkLocationPermission();
    // if (locationPermission == LocationPermission.deniedForever) {
    //   // Cannot request runtime permission because location permission is denied forever.
    //   return false;
    // } else 

    if(locationPermission == LocationPermission.always) return true;


   
    // if (locationPermission == LocationPermission.denied || locationPermission == LocationPermission.deniedForever || locationPermission == LocationPermission.whileInUse) {
      // Ask the user for location permission.
      locationPermission = await FlLocation.requestLocationPermission();

    //   if (locationPermission == LocationPermission.denied ||
    //       locationPermission == LocationPermission.deniedForever ||
    //       locationPermission == LocationPermission.whileInUse ) {
    //         return false;
    //         }
    // // }

    // Location permission must always be allowed (LocationPermission.always)
    // to collect location data in the background.
    // if (background == true &&
    //     locationPermission == LocationPermission.whileInUse) return false;

    // Location services has been enabled and permission have been granted.
    if(locationPermission == LocationPermission.always) return true;
    await AppSettings.openAppSettings();
    return false;
  }

  @override
  Widget build(BuildContext context) {
      final topHeight = MediaQuery.of(context).size.height * 0.25;
      final bottomHeight = MediaQuery.of(context).size.height * 0.75;
      final mediaWidth = MediaQuery.of(context).size.width;

      return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.grey[300],
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            reverse: true,
            child: Column(
            children: <Widget>[
              SizedBox(
                height: topHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        ClipPath(
                          clipper: _TrapeziumClipper1(),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1565C0),
                                  Color(0xFF37474F),
                                ],
                              ),
                            ),
                            // child: Center(
                            //   child: Text(
                            //     'Bus\nTracking',
                            //     style: TextStyle(
                            //       color: Colors.white,
                            //       fontSize: 25,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // ),
                          ),
                        ),
                        Positioned(
                          top: topHeight * 0.15,
                          left: (mediaWidth*0.35 - topHeight*0.5)/2 > 0 ? (mediaWidth*0.35 - topHeight*0.5)/2 : 10,
                          child: Container(
                            width: topHeight * 0.5,
                            height: topHeight * 0.5,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: topHeight * 0.49,
                                height: topHeight * 0.49,
                                child: Image.asset('assets/images/logo.png'),
                              ),
                            ),
                          ),
                          // child: SizedBox(
                          //   width: topHeight * 0.5,
                          //   height: topHeight * 0.5,
                          //   child: Image.asset('assets/images/logo.jpg'),
                          // ),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        ClipPath(
                          clipper: _TrapeziumClipper2(),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF1565C0),
                                  Color(0xFF37474F),
                                ],
                              ),
                            ),
    
                          ),
                        ),
                        Positioned(
                          top: topHeight * 0.35,
                          right: (mediaWidth*0.35 - topHeight*0.5)/2 > 0 ? (mediaWidth*0.35 - topHeight*0.5)/2 : 10,
                          child: SizedBox(
                            width: topHeight * 0.5,
                            height: topHeight * 0.5,
                            child: const Center(
                              child: Text("NWKRTC\nBUS\nTRACKING",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:FontWeight.bold,
                                color: Colors.white
                              ),
                              )
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              

              SizedBox(
                height: bottomHeight/10,
              ),
              Container(
                width: mediaWidth * 0.75,
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Fill color
                  borderRadius: BorderRadius.circular(15), // Border radius
                  // border: Border.all(
                  //   color: Colors.black, // Border color
                  //   width: 1, // Border width
                  // ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: topHeight/10,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                              'PERMISSION',
                              style: TextStyle(
                                  color:  Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 25),
                            )
                        ),
                        SizedBox(
                          height: topHeight/8,
                        ),

                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              "Bus tracking collects location data to enable sending your location to passengers of your bus even when the app is closed or not in use.",
                              style: TextStyle(fontSize: 16), 
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              "Please press agree and select 'allow all the time' to give permission",
                              style: TextStyle(fontSize: 16), 
                            ),
                          ),
                        ),

                        SizedBox(height: topHeight/8),
                        Container(
                          width: mediaWidth * 0.6,
                          height: topHeight/5,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            // color: !_isBusNumber ? null : Colors.grey.shade300,
                            gradient:  LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF37474F),
                              Color(0xFF1565C0),
                            ],
                          ),
                          ),
                          child: ElevatedButton(
                            
                            
                            style: ElevatedButton.styleFrom(
                              
                              primary: Colors.transparent,
                              onPrimary: Colors.white,
                              // padding: EdgeInsets.symmetric(
                              //   vertical: 16,
                              //   horizontal: 32,
                              // ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: (){
                              // print("asking something");
                              _checkAndRequestPermission(background: true).then((value){
                                // print("value is"+value.toString());
                                if(value== true){
                                  // print("popping");
                                  Navigator.of(context).pushReplacementNamed("/login");

                                  }
                                });
                              },
                            
                            
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'AGREE ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.check),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: topHeight/5)
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: topHeight/10)
            ],
          ),
          ),
        ),
      ),
    );

    // return Scaffold(
    //   body: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
        
    //      Padding(
    //        padding: const EdgeInsets.all(10.0),
    //        child: Column(
    //          children: [
    //            Center(
    //              child: Text(
    //               "Bus tracking collects location data to enable sending your location to passengers of your bus even when the app is closed or not in use.",
    //                style: TextStyle(fontSize: 18), 
    //             ),
    //            ),
    //           SizedBox(height: 20),

    //           Center(
    //              child: Text(
    //               "Please press agree and select 'allow all the time' to give permission",
    //                style: TextStyle(fontSize: 18), 
    //             ),
    //            ),

    //          ],
    //        ),
    //      ),
    //      SizedBox(height: 40,),
         
    //     ElevatedButton(
    //       style: ElevatedButton.styleFrom(primary: Colors.blue[800]),
    //       onPressed: (){
    //       // print("asking something");
    //       _checkAndRequestPermission(background: true).then((value){
    //         // print("value is"+value.toString());
    //         if(value== true){
    //           // print("popping");
    //           Navigator.of(context).pushReplacementNamed("/login");

    //         }
    //       });
    //     }, 
    //     child: Text("Agree")
    //     ) ,
        
    //   ]),
    // );
  }
}

class _TrapeziumClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // path.moveTo(size.width * 0.1, 0);
    path.moveTo(0, 0);
    path.lineTo(size.width , 0);
    path.lineTo(size.width * 0.7, size.height * 0.8);
    path.lineTo(0, size.height * 0.8);
    path.close();
    return path;
}

@override
bool shouldReclip(_TrapeziumClipper1 oldClipper) => false;
}

class _TrapeziumClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // path.moveTo(size.width * 0.1, 0);
    path.moveTo(size.width * 0.3, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
}

@override
bool shouldReclip(_TrapeziumClipper2 oldClipper) => false;
}