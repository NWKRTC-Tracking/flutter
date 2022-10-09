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