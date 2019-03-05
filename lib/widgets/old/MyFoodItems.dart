//import 'package:flutter/material.dart';
//import 'dart:io';
//import 'package:cloud_firestore/cloud_firestore.dart';
//
//import 'package:cookt/models/foodItems/FoodItem.dart';
//import 'package:cookt/widgets/old/FoodItemEditor.dart';
//
//class MyFoodItems extends StatefulWidget {
//  @override
//  _MyFoodItemsState createState() {
//    return _MyFoodItemsState();
//  }
//}
//
//class _MyFoodItemsState extends State<MyFoodItems> {
//  List<FoodItem> myFoodItems = [];
//  List<Widget> currentOrders = [];
//  Map<String, File> foodImaged = Map();
//  int numHosting = 0;
//
//  @override
//  Widget build(BuildContext context) {
//
//    loadData();
//
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('My Food Items'),
//      actions: <Widget>[
//        IconButton(
//          icon: Icon(Icons.add),
//          iconSize: 40.0,
//          onPressed: _showFoodItemEditor,
//        ),
//      ]
//      ),
//      body: ListView(
//        padding: const EdgeInsets.only(top: 16.0),
//        children: currentOrders.toList(),
//      ),
//    );
//  }
//
//  Future _showFoodItemEditor() async {
//    // push a new route like you did in the last section
//    Navigator.of(context).push(
//      MaterialPageRoute(
//        builder: (BuildContext context) {
//          return FoodItemEditor(reference: null,);
//        },
//      ),
//    );
//  }
//
//  void loadData() async {
//    await for (var snapshots in Firestore.instance
//        .collection("fooddata")
//        .where("uid", isEqualTo: "usercook")
//        .snapshots().asBroadcastStream()) {
//      for (int i = 0; i < snapshots.documentChanges.length; i++) {
//        FoodItem foodItem = FoodItem.fromSnapshot(snapshots.documents.elementAt(i));
//        if (!myFoodItems.contains(foodItem)){
//          setState(() {
//            myFoodItems.insert(numHosting, foodItem);
//            if(foodItem.isHosting){
//              numHosting++;
//            }
//            makeCurrentOrders();
//          });
//        }
//      }
//    }
//  }
//
//  void makeCurrentOrders(){
//    currentOrders = [];
//    for(FoodItem foodItem in myFoodItems){
//      currentOrders.add(_foodItemCell(foodItem));
//    }
//  }
//
//  Widget _foodItemCell(FoodItem foodItem) {
//    return Padding(
//      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//      child: Container(
//        decoration: BoxDecoration(
//          border: Border.all(color: Colors.grey),
//          borderRadius: BorderRadius.circular(5.0),
//        ),
//        child: FlatButton(
//          //color: Colors.red,
//          padding: EdgeInsets.all(0),
//          onPressed: (){
//            Navigator.of(context).push(
//              MaterialPageRoute(
//                builder: (BuildContext context) {
//                  return FoodItemEditor(reference: foodItem.reference,);
//                },
//              ),
//            );
//          },
//          child: Padding(
//            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
//            child: Row(
//              children: <Widget>[
//                ClipRRect(
//                  borderRadius: new BorderRadius.circular(2.0),
//                  child: Container(),//foodItem.smallFoodImage(context),
//                ),
//                Padding(padding: EdgeInsets.all(4.0),),
//                Text(foodItem.name),
//                Expanded(
//                  child: Container(),
//                ),
//                Switch.adaptive(
//                  value: foodItem.isHosting,
//                  onChanged: (bool newState) {
//                    if(newState)
//                      _presentDialog(foodItem);
//                    else {
//                      numHosting--;
//                      setState(() {
//                        Map<String, dynamic> map = Map();
//                        map['isHosting'] = newState;
//                        foodItem.reference.updateData(map);
//                        myFoodItems.remove(foodItem);
//                      });
//                    }
//                  },
//                )
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//
//  Future<void> _presentDialog(FoodItem foodItem) async {
//    return showDialog<void>(
//      context: context,
//      barrierDismissible: false, // user must tap button!
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: Text('Are you sure?'),
//          content: SingleChildScrollView(
//            child: ListBody(
//              children: <Widget>[
//                Text('Are you sure you want to start selling ${foodItem.name}? Be sure you are ready for incoming orders.'),
//              ],
//            ),
//          ),
//          actions: <Widget>[
//            FlatButton(
//              child: Text('Ok'),
//              onPressed: () {
//                Map<String, dynamic> map = Map();
//                map['isHosting'] = true;
//                setState(() {
//                  foodItem.reference.updateData(map);
//                  myFoodItems.remove(foodItem);
//                });
//                Navigator.of(context).pop();
//              },
//            ),
//            FlatButton(
//              child: Text('Cancel'),
//              onPressed: (){
//                // set to false
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }
//}
