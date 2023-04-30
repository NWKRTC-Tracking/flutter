import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:ui' as ui;

final CustomSpinner = SpinKitFadingFour(
  size: 60,
  itemBuilder: (BuildContext context, int index) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.blueGrey[800] : Colors.blue[800],
      ),
    );
  },
);

final CustomSpinnerWithTitle = SafeArea(
  child: Scaffold(
    appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        title: Text('NWKRTC'),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey,
      body: CustomSpinner,
  ),
);

// final CustomNewSpinner = SpinKitChasingDots(
//   size: 60,
//   itemBuilder: (BuildContext context, int index) {
//     return DecoratedBox(
//       decoration: BoxDecoration(
//         color: index.isEven ? Colors.blueGrey[800] : Colors.blue[800],
//       ),
//     );
//   },
// );

// final CustomNewSpinner = Container(
//   width: 50.0,
//   height: 50.0,
//   decoration: BoxDecoration(
//     gradient: LinearGradient(
//       colors: [Color(0xFF1565C0), Color(0xFF424242)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     ),
//     shape: BoxShape.circle,
//   ),
//   child: SpinKitChasingDots(
//     color: Colors.white,
//     size: 30.0,
//   ),
// );

final CustomNewSpinner = ShaderMask(
  shaderCallback: (bounds) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFF424242)],
    tileMode: TileMode.repeated,
  ).createShader(bounds),
  child: SpinKitRing(
    color: Colors.white,
    size: 60.0,
    lineWidth: 3.0,
    duration: Duration(milliseconds: 1500),
  ),
);

