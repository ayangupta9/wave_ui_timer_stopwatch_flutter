import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timer_project/screen_container.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.grey[900],
  ));

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScreensContainer(),
  ));
}
