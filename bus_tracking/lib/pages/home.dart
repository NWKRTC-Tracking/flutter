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
import 'package:bus_tracking/utils/busNoRegex.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

bool _initialURILinkHandled = false;

class _HomePageState extends State<HomePage> {

  void _autoLogOut(String value){
    var curTime = DateTime.now().millisecondsSinceEpoch;
    var prev = DateTime.fromMillisecondsSinceEpoch(int.parse(value));
    var cur = DateTime.fromMillisecondsSinceEpoch(curTime);
    DateTime dt1 = DateTime.parse(cur.toString());
    DateTime dt2 = DateTime.parse(prev.toString());
    Duration diff = dt1.difference(dt2);


    // ---------------Logout after 12 hours of trip generation ------------------------


    if(diff.inHours.toInt() >= 12){
      storage.deleteAll();
    }

  }

  @override
  void initState() {
    // var curTime = DateTime.now().millisecondsSinceEpoch;
    // storage.write(key: 'timeStamp',value: curTime.toString());
    super.initState();
    _focusNode = FocusNode();
    _focusNode2 = FocusNode();
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
  Future<String?> isValidData(String busOrPhoneNumber, bool _isBusNum) async {
    final msg;
    if(_isBusNum){
      msg = jsonEncode({"bus_no":busOrPhoneNumber});
    }
    else {
      msg = jsonEncode({"number":busOrPhoneNumber});
    }
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

  @override
  void dispose()async{
  _streamSubscription?.cancel();
  // await _storeTime();
  super.dispose();
  }


  bool _isBusNumber = true;

  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController2 = TextEditingController();

  late FocusNode _focusNode;
  late FocusNode _focusNode2;

  final _formKey = GlobalKey<FormState>();
  bool _isTrackPressed = false;


  @override
  Widget build(BuildContext context) {
    final topHeight = MediaQuery.of(context).size.height * 0.25;
    final bottomHeight = MediaQuery.of(context).size.height * 0.75;
    final mediaWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(child:  Scaffold(
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
              
    
              if(_isTrackPressed) ...[
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
                                'TRACK YOUR BUS',
                                style: TextStyle(
                                    color:  Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25),
                              )
                          ),
                          SizedBox(
                            height: topHeight/8,
                          ),
                        if(_isBusNumber) ...[
                            Visibility(
                            
                              visible: _isBusNumber,
                              child: Container(
                                width: mediaWidth * 0.6,
                                child: TextFormField(
                                  
                                  focusNode: _focusNode,
                                  controller: _textEditingController,
                                  cursorColor: Colors.black,
                                  keyboardType: _isBusNumber ? TextInputType.text : null,
                                  decoration: InputDecoration(
                                    labelText: "Bus Number",
                                            
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
                                    return null;
                                  },
                                ),
                              ),
                            ),
                        ]
                        else ...[
                          Visibility(
                            visible: !_isBusNumber,
                            child: Container(
                              width: mediaWidth * 0.6,
                              child: TextFormField(
                                maxLength: 10,
                                focusNode: _focusNode2,
                                controller: _textEditingController2,
                                cursorColor: Colors.black,
                                keyboardType: _isBusNumber ? null : TextInputType.phone,
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
                                  if(_isBusNumber) return null;
                                  if (value!.isEmpty || value.length != 10 ||
                                        !RegExp(r'^(?:(?:\+|0{0,2})91(\s*[\-]\s*)?|[0]?)?[6789]\d{9}$')
                                            .hasMatch(value)) {
                                      return 'Enter a valid Mobile number';
                                    }
                                  return null;
                                
                                },
                              ),
                            ),
                          ),
                        ],  
                        SizedBox(height: topHeight/8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isBusNumber = true;
                                  _textEditingController2.clear();
                                  _focusNode2.unfocus();
                                  _focusNode.requestFocus();
                                });
                              },
                              child: Container(
                                width: mediaWidth * 0.3,
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                  ),
                                  color: _isBusNumber ? null: Colors.grey.shade300,
                                  gradient: _isBusNumber ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF37474F),
                                      Color(0xFF1565C0),
                                    ],
                                  ) : null,
                                ),
                                child: const Center(
                                  child: Text(
                                    'BUS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isBusNumber = false;
                                  _textEditingController.clear();
                                  _focusNode.unfocus();
                                  _focusNode2.requestFocus();
                                });
                              },
                              child: Container(
                                width: mediaWidth * 0.3,
                  
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                  color: !_isBusNumber ? null : Colors.grey.shade300,
                                  gradient: !_isBusNumber ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF37474F),
                                    Color(0xFF1565C0),
                                  ],
                                ) : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'MOBILE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                            onPressed: () async {
                              var busOrPhoneNumber;
                                if(_isBusNumber){
                                  busOrPhoneNumber = _textEditingController.text.toString();
                                }
                                else{
                                  busOrPhoneNumber = _textEditingController2.text.toString();
                                }
                                // var phoneNo = phoneNoController.text.toString();
                                // var busNo = busNameController.text.toString();
                               
                                if(!_formKey.currentState!.validate()){
                                  return null;
                                }
                  
                                print("hi");
                                //Spinner
                                setState(() {
                                  _isTrackPressed = true;
                                });
                                // Navigator.pushNamed(context, '/location',arguments: locationData(phoneNo,busNo));
                                var apiKey = await isValidData(busOrPhoneNumber, _isBusNumber);
                                if(apiKey != null && apiKey != "null") {
                                  Navigator.pushNamed(context, '/location',arguments: locationKey(apiKey, busOrPhoneNumber));
                                } else {
                                  // AlertDialog(
                                  //   content: Text('Error occured'),
                                  // );
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
                            
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'TRACK ',
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: topHeight/5)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: topHeight/8),
              Container(
                width: mediaWidth * 0.5,
                child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(8),
                            child: IconButton(
                              icon: Icon(Icons.login),
                              onPressed: (){
                                storage.read(key: 'timeStamp').then((value){
                                  if(value != null){
                                    _autoLogOut(value);
                                  }
                                });
                                // ignore: use_build_context_synchronously
                                Navigator.pushNamed(context, '/login');
                              }, 
                            ),
                          ),
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(8),
                              child: IconButton(
                                icon: Icon(Icons.link),
                                onPressed: () {
                                  launch('https://tracknwkrtc.in/');
                                },
                              ),
                            ),
                          ),
                        ],
                      )
              ),
              SizedBox(height: topHeight/10)
              ]
            ],
          ),
        ),
      )
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





