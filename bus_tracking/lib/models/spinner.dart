import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

final CustomNewSpinner = SpinKitFadingFour(
  size: 60,
  itemBuilder: (BuildContext context, int index) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.blueGrey[800] : Colors.blue[800],
      ),
    );
  },
);