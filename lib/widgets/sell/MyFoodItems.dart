import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/services/Services.dart';
import 'package:cookt/widgets/foodItems/EditFoodItem.dart';

class MyFoodItems extends StatefulWidget {

  @override
  _MyFoodItemsState createState() => _MyFoodItemsState();
}

class _MyFoodItemsState extends State<MyFoodItems> {
  List<FoodItem> myFoodItems = [];
  Map<String, File> foodImaged = Map();

  _MyFoodItemsState(){
   Firestore.instance
        .collection("fooddata")
        .where("uid", isEqualTo: "usercook")
        .orderBy('isHosting', descending: true)
        .getDocuments().then((onValue) {
      setState(() {
        myFoodItems = onValue.documents.map((snapshot) => FoodItem.fromSnapshot(snapshot)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Food Items'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          iconSize: 40.0,
          onPressed: _showFoodItemEditor,
        ),
      ]
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16.0),
        children: myFoodItems.map((foodItem) => _foodItemCell(foodItem)).toList(),
      ),
    );
  }

  Future _showFoodItemEditor() async {
    // push a new route like you did in the last section
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return EditFoodItem(reference: null,);
        },
      ),
    );
  }

  Widget _foodItemCell(FoodItem foodItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
            )
          ],
          color: Theme.of(context).cardColor,
        ),
        child: FlatButton(
          //color: Colors.red,
          padding: EdgeInsets.all(0),
          onPressed: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return EditFoodItem(reference: foodItem.reference,);
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
            child: Row(
              children: <Widget>[
//                ClipRRect(
//                  borderRadius: new BorderRadius.circular(2.0),
//                  child:
                  foodItem.image != null? Container(height: 75, width: 75, child: Services.foodImage(foodItem.image),) : Container(color: Colors.grey, child: Center(child: Icon(Icons.image),),),
//                ),
                Padding(padding: EdgeInsets.all(4.0),),
                Text(foodItem.name, style: Theme.of(context).textTheme.subtitle.apply(fontSizeFactor: 1.2,),),
                Expanded(
                  child: Container(),
                ),
                Switch.adaptive(
                  value: foodItem.isHosting,
                  onChanged: (bool newState) {
                    if(newState)
                      _presentDialog(foodItem);
                    else {
                      setState(() {
                        Map<String, dynamic> map = Map();
                        map['isHosting'] = newState;
                        foodItem.reference.updateData(map);
                        foodItem.isHosting = false;
                      });
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _presentDialog(FoodItem foodItem) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to start selling ${foodItem.name}s? Be sure you are ready for incoming orders.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Map<String, dynamic> map = Map();
                map['isHosting'] = true;
                foodItem.reference.updateData(map);
                setState(() {
                  foodItem.isHosting = true;
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: (){
                // set to false
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
