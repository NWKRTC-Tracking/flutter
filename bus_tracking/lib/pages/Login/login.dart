import 'dart:convert';

import 'package:bus_tracking/config/url.dart';
import 'package:bus_tracking/models/logo.dart';
import 'package:bus_tracking/models/spinner.dart';
import 'package:bus_tracking/pages/sendLocationCheck.dart';
import 'package:bus_tracking/pages/getLocationPermission/permission.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_location/fl_location.dart';


import '../../main.dart';
 
class Login extends StatelessWidget {

   Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if(jwt == null) return "";
    return jwt;
  }
  Future<bool> get permissionPresent async {
    var l = FlLocation.checkLocationPermission();
    if(l!= LocationPermission.always){
      return false;
    }
    return true;

  }


  const Login({Key? key}) : super(key: key);
 
  static const String _title = 'NWKRTC';


 
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          // appBar: AppBar(title: const Text(_title)),
          // body: LoginWidget(),
          body: FutureBuilder(
          future: jwtOrEmpty,
                       
          builder: (context, snapshot) {
            print("getting location permission value ");
            FlLocation.checkLocationPermission().then((value){
              print(value);
              if(value != LocationPermission.always){
                print("should have went somewhere");
                Navigator.of(context).pushReplacementNamed("/permission");
              }
            });
            if(!snapshot.hasData) return LoginWidget();
            if(snapshot.data != "") {
              var str = snapshot.data.toString();
              var jwt = str.split(".");
              if(jwt.length !=3) {
                return LoginWidget();
              } else {
                var payload = json.decode(ascii.decode(base64.decode(base64.normalize(jwt[1]))));
                if(DateTime.fromMillisecondsSinceEpoch(payload["exp"]*1000).isAfter(DateTime.now())) {
                  return sendLocationCheck();
                } else {
                  return LoginWidget();
                }
              }
            } else {
              return LoginWidget();
            }
          }
        ),
        ),
    );
  }
}
 
class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);
 
  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}
 
class _LoginWidgetState extends State<LoginWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false, _isLoginPressed = false;

  late String token;
  String errorMsg = "Invalid Credentials";
  var _formKey = GlobalKey<FormState>();

  Future<String?> attemptLogIn(String phoneNo, String password) async {
    final msg = jsonEncode({"phoneNo":phoneNo,"password":password,});
    Map<String,String> headers = {'Content-Type':'application/json'};
    var response = await post(
      Uri.parse(getUrl()+'login/'),
      headers: headers,
      body: msg,
    );
    

    if(response.statusCode == 200){ 
      setState(() {
        token = jsonDecode(response.body)['token'].toString();
        _isLoginPressed = false;
      });
      return response.body;
    }
    setState(() {
      errorMsg = jsonDecode(response.body)['message'].toString();
      _isLoginPressed = false;
    });
    if(errorMsg == null){
      setState(() {
        errorMsg = "Invalid Data";
      });
      
    }
    return null;
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
              Container(
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
                            decoration: BoxDecoration(
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
                            decoration: BoxDecoration(
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
                            decoration: BoxDecoration(
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
                          child: Container(
                            width: topHeight * 0.5,
                            height: topHeight * 0.5,
                            child: Center(
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
              
    
              if(_isLoginPressed) ...[
                Padding(
                  padding: EdgeInsets.only(
                    top: (bottomHeight - 60)/2 > 0 ? (bottomHeight - 60)/2 : 40
                  ),
                  child: CustomNewSpinner,
                )
              ]
    
              else ...[
    
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: topHeight/10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: const Text(
                                'LOGIN',
                                style: TextStyle(
                                    color:  Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25),
                              )
                          ),
                          SizedBox(
                            height: topHeight/8,
                          ),
                        
                            
                       
                        Container(
                          width: mediaWidth * 0.6,
                          child: TextFormField(
                            maxLength: 10,
                            controller: nameController,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText:  "Mobile Number",
                            
                              labelStyle: TextStyle(color: Colors.black, fontSize: 15),
                              
                              fillColor: Colors.grey[200],
                              filled: true,
                                    
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0), // rounded border
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0), // rounded border
                                borderSide: BorderSide(color: Color(0xFFEEEEEE)), // border color
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0), // rounded border
                                borderSide: BorderSide(color: Colors.black), // border color
                              ),
                              
                            ),
                            validator: (value){
                              if (value!.isEmpty || value.length != 10 ||
                                    !RegExp(r'^(?:(?:\+|0{0,2})91(\s*[\-]\s*)?|[0]?)?[6789]\d{9}$')
                                        .hasMatch(value)) {
                                  return 'Enter a valid Mobile number';
                                }
                              return null;
                            
                            },
                          ),
                        ),
                        SizedBox(height: topHeight/8),

                        Container(
                          width: mediaWidth * 0.6,
                          child: TextFormField(
                          maxLength: 30,
                          obscureText: !_passwordVisible,
                          controller: passwordController,
                          validator: (value) {
                            if (value!.length < 1) {
                              return 'Enter Password';
                            }
                            return null;
                          },
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText:  "Password",
                            
                              labelStyle: TextStyle(color: Colors.black, fontSize: 15),
                              
                              fillColor: Colors.grey[200],
                              filled: true,
                                    
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0), // rounded border
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0), // rounded border
                                borderSide: BorderSide(color: Color(0xFFEEEEEE)), // border color
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0), // rounded border
                                borderSide: BorderSide(color: Colors.black), // border color
                              ),

                              suffixIcon: IconButton(
                              onPressed: (){
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(
                                _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                                color: Colors.black,
                              )
                            )
                              
                            ),
                            
                          ),
                        ),
                                                 
                        SizedBox(height: topHeight/8),
                        Container(
                          width: mediaWidth * 0.6,
                          height: topHeight/5,
                          decoration: BoxDecoration(
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
                            
                            
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ENTER ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
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
                            onPressed: () async {
                              if(!_formKey.currentState!.validate()){
                              return null;
                              }
                              setState(() {
                                _isLoginPressed = true;
                              });
                              var username = nameController.text.toString();
                              var password = passwordController.text.toString();
                              var jwt = await attemptLogIn(username, password);
                              if(jwt != null) {
                                await storage.write(key: "token", value: token);
                                await storage.write(key: "jwt", value: jwt);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => sendLocationCheck(),
                                  )
                                );
                              } else {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    
                                      backgroundColor: Colors.grey[300],
                                      
                                      elevation: 2.0,
                                      title:  Center(child: Text(errorMsg)),
                                                          
                                      actionsAlignment: MainAxisAlignment.center,
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, 'OK'),
                                          child: const Text('OK',style: TextStyle(color: Color(0xFF1565C0)),),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                            },
                          ),
                        ),
                        SizedBox(height: topHeight/5)
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: topHeight/10)
              ]
            ],
          ),
            // child: Padding(
            //     padding: const EdgeInsets.all(15),
            //     child: Form(
            //       key: _formKey,
            //       child: Column(
            //         children: <Widget>[
            //           mainLogo,
            //           Container(
            //               alignment: Alignment.center,
            //               padding: const EdgeInsets.all(10),
            //               child: const Text(
            //                 'LOGIN',
            //                 style: TextStyle(
            //                     color: Colors.black,
            //                     fontWeight: FontWeight.w500,
            //                     fontSize: 30),
            //               )),
            //           Container(
            //             padding: const EdgeInsets.all(15.0),
                  
            //             child: TextFormField(
            //               keyboardType: TextInputType.number,
            //               cursorColor: Colors.black,
            //               controller: nameController,
            //               maxLength: 10,
            //               validator: (value){
            //               if (value!.isEmpty || value.length != 10 ||
            //                     !RegExp(r'^(?:(?:\+|0{0,2})91(\s*[\-]\s*)?|[0]?)?[6789]\d{9}$')
            //                         .hasMatch(value)) {
            //                   return 'Enter a valid Mobile number';
            //                 }
            //               return null;
          
            //               },
            //               decoration: const InputDecoration(
            //                 focusedBorder: OutlineInputBorder(
            //                   borderRadius: BorderRadius.all(Radius.circular(4)),
            //                   borderSide: BorderSide(width: 1,color: Colors.black),
            //                 ),
            //                 counter: SizedBox(
            //                   width: 0,
            //                   height: 0,
            //                 ),
            //                 border: OutlineInputBorder(),
            //                 labelStyle: TextStyle(color: Colors.black),
            //                 labelText: 'Mobile No',
            //               ),
            //             ),
            //           ),
            //           Container(
            //             padding: const EdgeInsets.all(15.0),
            //             child: TextFormField(
            //               cursorColor: Colors.black,
                          // obscureText: !_passwordVisible,
                          // controller: passwordController,
                          // validator: (value) {
                          //   if (value!.length < 1) {
                          //     return 'Enter Password';
                          //   }
                          //   return null;
                          // },
            //               decoration: InputDecoration(
            //                 focusedBorder: OutlineInputBorder(
            //                   borderRadius: BorderRadius.all(Radius.circular(4)),
            //                   borderSide: BorderSide(width: 1,color: Colors.black),
            //                 ),
                            
            //                 border: OutlineInputBorder(),
            //                 labelText: 'Password',
            //                 labelStyle: TextStyle(color: Colors.black),
            //                 suffixIcon: IconButton(
            //                   onPressed: (){
            //                     setState(() {
            //                       _passwordVisible = !_passwordVisible;
            //                     });
            //                   },
            //                   icon: Icon(
            //                     _passwordVisible
            //                     ? Icons.visibility_off
            //                     : Icons.visibility,
            //                     color: Colors.black,
            //                   )
            //                 )
            //               ),
            //             ),
            //           ),
            //           SizedBox(height: 20,),
            //           Container(
            //               height: 80,
            //               padding: const EdgeInsets.all(15.0),
            //               child: ElevatedButton(
            //                 style: ElevatedButton.styleFrom(primary: Colors.blue[800]),
            //                 child: const Text('Login'),
            //                 onPressed: () async {
            //                   if(!_formKey.currentState!.validate()){
            //                   return null;
            //                   }
            //                   setState(() {
            //                     _isLoginPressed = true;
            //                   });
            //                   var username = nameController.text.toString();
            //                   var password = passwordController.text.toString();
            //                   var jwt = await attemptLogIn(username, password);
            //                   if(jwt != null) {
            //                     await storage.write(key: "token", value: token);
            //                     await storage.write(key: "jwt", value: jwt);
            //                     Navigator.push(
            //                       context,
            //                       MaterialPageRoute(
            //                         builder: (context) => sendLocationCheck(),
            //                       )
            //                     );
            //                   } else {
            //                     showDialog<String>(
            //                       context: context,
            //                       builder: (BuildContext context) => AlertDialog(
            //                         // backgroundColor: Colors.redAccent[300],
                                    
            //                         elevation: 1.0,
            //                         title:  Center(child: Text(errorMsg)),
                                                        
            //                         actionsAlignment: MainAxisAlignment.center,
            //                         actions: <Widget>[
            //                           TextButton(
            //                             onPressed: () => Navigator.pop(context, 'OK'),
            //                             child: const Text('OK',style: TextStyle(color:Colors.black),),
            //                           ),
            //                         ],
            //                       ),
            //                       );
            //                     }
            //                 },
            //               )
            //           ),
            //         ],
            //       ),
            //     )),
          ),
        ),
      ),
    );
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