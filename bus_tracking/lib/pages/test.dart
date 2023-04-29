import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isBusNumber = true;

  TextEditingController _textEditingController = TextEditingController();

  late FocusNode _focusNode;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final topHeight = MediaQuery.of(context).size.height * 0.25;
    final bottomHeight = MediaQuery.of(context).size.height * 0.75;
    final mediaWidth = MediaQuery.of(context).size.width;
    return SafeArea(child:  Scaffold(
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
            SizedBox(
              height: bottomHeight/6,
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
                      height: topHeight/5,
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
                            focusNode: _focusNode,
                            controller: _textEditingController,
                            cursorColor: Colors.black,
                            keyboardType: _isBusNumber ? null : TextInputType.text,
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
                            child: Center(
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
                        onPressed: () {
                          // Handle button press
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
          ],
        ),
      ),
    )
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





