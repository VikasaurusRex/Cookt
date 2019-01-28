import 'package:flutter/material.dart';


import 'package:cookt/widgets/foodIemEditor.dart';
import 'package:cookt/widgets/currentOrders.dart';
import 'package:cookt/widgets/foodItemView.dart';
import 'package:cookt/widgets/myFoodItems.dart';
import 'package:cookt/widgets/categoryView.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cookt",
      home: CategoryView(),
      theme: ThemeData(
        //primaryColor: Colors.blue,
      ),
    );
  }
}