// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';

final mainLogo = Container(
  width: 150.0,
  height: 150.0,
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
    image: DecorationImage(
        fit: BoxFit.fill,
        image: AssetImage('assets/images/logo.png'),
    ),
  )
);