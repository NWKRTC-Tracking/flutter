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
    return _isLoginPressed ? CustomSpinnerWithTitle : SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.blueGrey[800],
            title: Text('NWKRTC'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            reverse: true,
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      mainLogo,
                      Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 30),
                          )),
                      Container(
                        padding: const EdgeInsets.all(15.0),
                  
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          cursorColor: Colors.black,
                          controller: nameController,
                          maxLength: 10,
                          validator: (value){
                          if (value!.isEmpty || value.length != 10 ||
                                !RegExp(r'^(?:(?:\+|0{0,2})91(\s*[\-]\s*)?|[0]?)?[6789]\d{9}$')
                                    .hasMatch(value)) {
                              return 'Enter a valid Mobile number';
                            }
                          return null;
          
                          },
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: Colors.black),
                            ),
                            counter: SizedBox(
                              width: 0,
                              height: 0,
                            ),
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.black),
                            labelText: 'Mobile No',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          obscureText: !_passwordVisible,
                          controller: passwordController,
                          validator: (value) {
                            if (value!.length < 1) {
                              return 'Enter Password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: Colors.black),
                            ),
                            
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.black),
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
                      SizedBox(height: 20,),
                      Container(
                          height: 80,
                          padding: const EdgeInsets.all(15.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.blue[800]),
                            child: const Text('Login'),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => sendLocationCheck(),
                                  )
                                );
                              } else {
                                showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    // backgroundColor: Colors.redAccent[300],
                                    
                                    elevation: 1.0,
                                    title:  Center(child: Text(errorMsg)),
                                                        
                                    actionsAlignment: MainAxisAlignment.center,
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, 'OK'),
                                        child: const Text('OK',style: TextStyle(color:Colors.black),),
                                      ),
                                    ],
                                  ),
                                  );
                                }
                            },
                          )
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}