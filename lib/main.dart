import 'package:flutter/material.dart';

import 'package:cookt/widgets/foodIemEditor.dart';
import 'package:cookt/widgets/currentOrders.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cookt",
      home: CurrentOrders(),
      theme: ThemeData(
        primaryColor: Colors.black,
        highlightColor: Colors.black12,
        hintColor: Colors.black,
      ),
    );
  }
}