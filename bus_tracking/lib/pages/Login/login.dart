import 'dart:convert';
import 'dart:html';

import 'package:bus_tracking/pages/sendLocation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
 
class Login extends StatelessWidget {

   Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if(jwt == null) return "";
    return jwt;
  }


  const Login({Key? key}) : super(key: key);
 
  static const String _title = 'NWKRTC';
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text(_title)),
        // body: LoginWidget(),
        body: FutureBuilder(
        future: jwtOrEmpty,            
        builder: (context, snapshot) {
          if(!snapshot.hasData) return LoginWidget();
          if(snapshot.data != "") {
            var str = snapshot.data.toString();
            var jwt = str.split(".");
            if(jwt.length !=3) {
              return LoginWidget();
            } else {
              var payload = json.decode(ascii.decode(base64.decode(base64.normalize(jwt[1]))));
              if(DateTime.fromMillisecondsSinceEpoch(payload["exp"]*1000).isAfter(DateTime.now())) {
                return sendLocation();
              } else {
                return LoginWidget();
              }
            }
          } else {
            return LoginWidget();
          }
        }
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

  Future<String?> attemptLogIn(String phoneNo, String password) async {
    final msg = jsonEncode({"phoneNo":phoneNo,"password":password,});
      Map<String,String> headers = {'Content-Type':'application/json'};
    var response = await post(
      Uri.parse('http://10.196.7.251:8080/api/login/'),
      headers: headers,
      body: msg,
    );
    

    if(response.statusCode == 200){ 
      storage.write(key: "token", value: (jsonDecode(response.body)['token']));
      return response.body;
      }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Mobile No',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                //forgot password screen
              },
              child: const Text('Forgot Password',),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  child: const Text('Login'),
                  onPressed: () async {
                    var username = nameController.text.toString();
                    var password = passwordController.text.toString();
                    print(username+password);
                    var jwt = await attemptLogIn(username, password);
                    if(jwt != null) {
                      storage.write(key: "jwt", value: jwt);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => sendLocation(),
                        )
                      );
                    } else {
                      AlertDialog(semanticLabel: "An Error Occurred No account was found matching that username and password");
                    }
                  },
                )
            ),
          ],
        ));
  }
}