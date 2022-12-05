import 'dart:async';
import 'dart:convert';
import 'package:bus_tracking/config/url.dart';
import 'package:bus_tracking/main.dart';
import 'package:bus_tracking/models/locationKey.dart';
import 'package:bus_tracking/models/logo.dart';
import 'package:bus_tracking/models/spinner.dart';
import 'package:bus_tracking/pages/location.dart';
import 'package:bus_tracking/services/displayMap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uni_links/uni_links.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
bool _initialURILinkHandled = false;




class _HomeState extends State<Home> {

  void _autoLogOut(String value){
    var curTime = DateTime.now().millisecondsSinceEpoch;
    var prev = DateTime.fromMillisecondsSinceEpoch(int.parse(value));
    var cur = DateTime.fromMillisecondsSinceEpoch(curTime);
    DateTime dt1 = DateTime.parse(cur.toString());
    DateTime dt2 = DateTime.parse(prev.toString());
    Duration diff = dt1.difference(dt2);
    if(diff.inHours.toInt() >= 15){
      storage.deleteAll();
    }
  }



  @override
  void initState() {
    // var curTime = DateTime.now().millisecondsSinceEpoch;
    // storage.write(key: 'timeStamp',value: curTime.toString());
    super.initState();
  _initURIHandler();
  _incomingLinkHandler();
  // _storeTime();
    // _locationController = StreamController();
  }

  Uri? _initialURI;
  Uri? _currentURI;
  Object? _err;
  StreamSubscription? _streamSubscription;
  void _incomingLinkHandler() {
  // 1
  if (!kIsWeb) {
    // 2
    _streamSubscription = uriLinkStream.listen((Uri? uri) {
      if (!mounted) {
        return;
      }
      debugPrint('Received URI: $uri');
      setState(() {
        _currentURI = uri;
        _err = null;
      });
      // 3
    }, onError: (Object err) {
      if (!mounted) {
        return;
      }
      debugPrint('Error occurred: $err');
      setState(() {
        _currentURI = null;
        if (err is FormatException) {
          _err = err;
        } else {
          _err = null;
        }
      });
    });
  }
  }

  Future<void> _initURIHandler() async {
 // 1
  if (!_initialURILinkHandled) {
    _initialURILinkHandled = true;
    // 2
    // Fluttertoast.showToast(
    //     msg: "Invoked _initURIHandler",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.BOTTOM,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.green,
    //     textColor: Colors.white
    // );
    try {
      // 3
      final initialURI = await getInitialUri();
      // 4
      if (initialURI != null) {
        debugPrint("Initial URI received $initialURI");
        if (!mounted) {
          return;
        }
        setState(() {
          _initialURI = initialURI;
        });
      } else {
        debugPrint("Null Initial URI received");
      }
    } on PlatformException { // 5
      debugPrint("Failed to receive initial uri");
    } on FormatException catch (err) { // 6
      if (!mounted) {
        return;
      }
      debugPrint('Malformed Initial URI received');
      setState(() => _err = err);
    }
  }
  }
  String errorMsg = "Invalid Data";
  Future<String?> isValidData(String phoneNo, String busNo) async {
    final msg = jsonEncode({"number":phoneNo,"bus_no":busNo});
      Map<String,String> headers = {'Content-Type':'application/json'};
    var response = await http.post(
      Uri.parse(getUrl() +  'get-key/'),
      headers: headers,
      body: msg,
    );
    
    if(response.statusCode == 200){ 
      // setState(() {
      //   apiKey = jsonDecode(response.body)['key'].toString();
      // });
      setState(() {
        _isTrackPressed = false;
      });
      return jsonDecode(response.body)['key'].toString();
    
    }
    setState(() { 
      errorMsg = jsonDecode(response.body)['message'].toString();
      _isTrackPressed = false;
    });
    if(errorMsg == "null"){
      setState(() {
        errorMsg = "Invalid Data";
      });
    }

    return null;
  }
  // @override
  // void initState() {
  // super.initState();
  // // _initURIHandler();
  // // _incomingLinkHandler();
  // }

  @override
  void dispose()async{
  _streamSubscription?.cancel();
  // await _storeTime();
  super.dispose();
  }

  TextEditingController phoneNoController = TextEditingController();
  TextEditingController busNameController = TextEditingController();

  bool _isTrackPressed = false;
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return _isTrackPressed ? CustomSpinnerWithTitle : SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset : true,
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            backgroundColor: Colors.blueGrey[800],
            // backgroundColor: Color.fromARGB(255, 193, 72, 31),
            title: Text('NWKRTC'),
            centerTitle: true,
            actions: [
              FlatButton.icon(
                onPressed: (){
                 print('login button');
                storage.read(key: 'timeStamp').then((value){
                  if(value != null){
                    print('value not null');
                    _autoLogOut(value);
                  }
                });
                // ignore: use_build_context_synchronously
                Navigator.pushNamed(context, '/login');
              }, 
              icon: Icon(
                Icons.login,
                color: Colors.white,
              ), label: Text('Login',style: TextStyle(color: Colors.white),),)
            ],
          ),
          body: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    //Logo
                    mainLogo,
                    Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(15),
                        child: const Text(
                          'Track Your Bus',
                          style: TextStyle(
                              color:  Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 30),
                        )),
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                       keyboardType: TextInputType.number,
                        controller: phoneNoController,
                        validator: (value){
                          if (value!.length != 10) {
                          return 'Enter a valid mobile number';
                        }
                        return null;
                       },
                      
                        
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: Colors.black),
                            ),
                            
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.black),
                          labelText: 'Conductor Number',
                          
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        controller: busNameController,
                        cursorColor: Colors.black,
                        validator: (value){
                          // if (value!.isEmpty ||
                          //       !RegExp("^[A-Z]{1}[0-9]{4}\$")
                          //           .hasMatch(value)) {
                          //     return 'Enter a valid Bus No';
                          //   }
                            return null;
                        },
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide: BorderSide(width: 1,color: Colors.black),
                            ),
                            
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.black),
                          labelText: 'Bus No',
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                        height: 50,
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.blue[800] ),
                          child: const Text('Track'),
                          
                          onPressed: () async {
                            var phoneNo = phoneNoController.text.toString();
                            var busNo = busNameController.text.toString();
                           
                            if(!_formKey.currentState!.validate()){
                              return null;
                            }
                            //Spinner
                            setState(() {
                              _isTrackPressed = true;
                            });
                            // Navigator.pushNamed(context, '/location',arguments: locationData(phoneNo,busNo));
                            var apiKey = await isValidData(phoneNo, busNo);
                            if(apiKey != null && apiKey != "null") {
                              Navigator.pushNamed(context, '/location',arguments: locationKey(apiKey, busNo));
                            } else {
                              // AlertDialog(
                              //   content: Text('Error occured'),
                              // );
                              showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                // backgroundColor: Colors.redAccent[300],
                                
                                elevation: 1.0,
                                title:  Center(child: Text(errorMsg)),
                                // content:  Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   children : <Widget>[
                                //     Expanded(
                                //       child: Text(
                                //         'Invalid Data',
                                //         textAlign: TextAlign.center,
                                        
                                //       ),
                                //     )
                                //   ],
                                // ),                      
                                actionsAlignment: MainAxisAlignment.center,
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'OK'),
                                    child: const Text('OK',style: TextStyle(color: Color.fromARGB(255, 39, 91, 42)),),
                                  ),
                                ],
                              ),
                              );
                          
                            }
                          },
                        )
                    )
                  ]
                ),
              ),
            ),
          )
        ),
      ),
    );
  }
}

        