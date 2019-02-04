import 'package:flutter/material.dart';


import 'package:cookt/widgets/FoodItemEditor.dart';
import 'package:cookt/widgets/CurrentOrderSummary.dart';
import 'package:cookt/widgets/FoodItemView.dart';
import 'package:cookt/widgets/MyFoodItems.dart';
import 'package:cookt/widgets/CategoryView.dart';
import 'package:cookt/widgets/MyCart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cookt",
      home: MyCart(),
      theme: ThemeData(
        //primaryColor: Colors.blue,
      ),
    );
  }
}