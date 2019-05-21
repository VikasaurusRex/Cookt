import 'package:flutter/material.dart';

import 'package:cookt/models/DatabaseIntegrator.dart';

class MyFoodItems extends StatefulWidget {
  final Color color;

  MyFoodItems(this.color);

  @override
  State<StatefulWidget> createState() =>_MyFoodItemsState();
}

class _MyFoodItemsState extends State<MyFoodItems> {
  String _name = "";

  void loadData() {
    DatabaseIntegrator.foodName("1yzdDBacqdeRxewvuczy").then((val) => setState(() {
      _name = val;
    }));
  }

  _MyFoodItemsState(){
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      child: Center(
        child: Text(_name),
      ),
    );
  }
}