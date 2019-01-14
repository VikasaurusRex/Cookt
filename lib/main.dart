import 'package:flutter/material.dart';

import 'package:cookt/widgets/foodIemEditor.dart';
import 'package:cookt/widgets/currentOrders.dart';
import 'package:cookt/widgets/foodItemView.dart';
import 'package:cookt/widgets/myFoodItems.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cookt",
      home: FoodItemView(),
      theme: ThemeData(
        primaryColor: Colors.black,
        highlightColor: Colors.black12,
        hintColor: Colors.black,
      ),
    );
  }
}