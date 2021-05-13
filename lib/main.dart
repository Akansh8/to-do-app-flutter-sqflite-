import 'package:flutter/material.dart';
import 'package:todo/ui/home.dart';

void main(List<String> args) {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY TO-DO',
      home: new Home(),
    );
  }
}
