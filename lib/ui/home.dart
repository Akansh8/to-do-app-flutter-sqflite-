import 'package:flutter/material.dart';
import 'package:todo/ui/todo_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TO-DO"),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),
      body: new todoScreen(),
    );
  }
}
