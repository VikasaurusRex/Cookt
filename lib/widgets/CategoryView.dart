import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/FoodItem.dart';
import 'FoodItemView.dart';

class CategoryView extends StatefulWidget {
  @override
  _CategoryViewState createState() {
    return _CategoryViewState();
  }
}

class _CategoryViewState extends State<CategoryView> {
  List<FoodItem> foodItems = [];
  List<Widget> foodItemCells = [];
  Map<String, File> foodImaged = Map();
  String category = 'Indian';

  @override
  Widget build(BuildContext context) {
    loadData();

    return Scaffold(
      appBar: AppBar(
          title: Text('$category Food'),
          actions: <Widget>[
            IconButton(
              onPressed: (){setState(() {
                foodItemCells = [];
                for(FoodItem item in foodItems)
                  foodItemCells.add(_foodItemCell(item));
              });},
              icon: Icon(Icons.refresh),
            )
          ]
      ),
      body: ListView(
        children: foodItemCells.toList(),
      ),
    );
  }

  void loadData() async {
    await for (var snapshots in Firestore.instance
        .collection("fooddata")
        .where("categories", arrayContains: "$category")
        .snapshots().asBroadcastStream()) {

      for (int i = 0; i < snapshots.documentChanges.length; i++) {
        FoodItem foodItem = FoodItem.fromSnapshot(snapshots.documents.elementAt(i));
        if (!foodItems.contains(foodItem)){
          print(foodItem.name);
          foodItems.add(foodItem);
          setState(() {
            foodItemCells.add(_foodItemCell(foodItems[i]));
          });
        }
      }
    }
  }

  Widget _foodItemCell(FoodItem foodItem) {

    int i = 0;
    List<Widget> bubbles = [];
    while(i < foodItem.categories.length && bubbles.length < 2) {
      if (foodItem.categories[i] != category) {
        bubbles.add(_bubbleBuilder(foodItem.categories[i]));
      }
      i++;
    }
    bubbles.insert(0, _bubbleBuilder('\$${foodItem.price.toStringAsFixed(2)}'));
    bubbles.insert(1, _bubbleBuilder(category));

    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: (){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return FoodItemView(reference: foodItem.reference,);
            },
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: new BorderRadius.circular(0.0),
            child: foodItem.largeFoodImage(context),
          ),
          Padding(padding: EdgeInsets.all(4.0),),
          Text(foodItem.name, style: Theme.of(context).textTheme.headline,),
          Padding(padding: EdgeInsets.all(4.0),),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: bubbles,
          ),
          Padding(padding: EdgeInsets.all(8.0),),
        ],
      ),
    );
  }

  Widget _bubbleBuilder(String text){
    return Padding(
      padding: EdgeInsets.all(4.0),
      child:Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Text(text, style: Theme.of(context).textTheme.subhead,),
        ),
      ),
    );
  }
}
