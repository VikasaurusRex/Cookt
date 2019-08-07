import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/User.dart';
import 'package:cookt/models/DatabaseIntegrator.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/widgets/search/FoodItemTile.dart';

class StoreOverview extends StatefulWidget {

  User cook;

  StoreOverview(this.cook);

  @override
  _StoreOverviewState createState() => _StoreOverviewState();
}

class _StoreOverviewState extends State<StoreOverview> {

  // TODO: Model Profile after gofundme or kickstarter or spotify

  List<FoodItem> myFoodItems = [];
  Map<String, File> foodImaged = Map();

  _StoreOverviewState(){
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
      //backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(title: Text('${widget.cook.kitchenname}'),),
      body: ListView(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: DatabaseIntegrator.userImage(widget.cook.reference.documentID)
          ),
          widget.cook.about != null? _textBox(widget.cook.about): Container(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4.0),
            child: Text(
              'From: ${widget.cook.hometown}',
              style: Theme.of(context).textTheme.headline.apply(
                fontSizeFactor: 0.6
            ),),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: Container(
              height: 1,
              color: Colors.black12,
            ),
          ),
          widget.cook.because != null? _sectionTitle('I cook because...'): Container(),
          widget.cook.because != null? _textBox(widget.cook.because): Container(),
          widget.cook.favFood != null? _sectionTitle('Favorite food'): Container(),
          widget.cook.favFood != null? _textBox(widget.cook.favFood): Container(),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: Container(
              height: 1,
              color: Colors.black12,
            ),
          ),
          _title('My Selection'),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: myFoodItems.map((foodItem) => FoodItemTile(foodItem, widget.cook, false, key: Key(foodItem.toString()))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _title(String text){
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 10, 0, 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.subhead.apply(
          fontWeightDelta: 2,
          fontSizeFactor: 2
        ),
      ),
    );
  }

  Widget _sectionTitle(String text){
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 20, 0, 0),
      child: Text(text, style: Theme.of(context).textTheme.subhead),// textAlign: TextAlign.center,),
    );
  }

  Widget _textBox(String text){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.subhead.apply(
          fontWeightDelta: 2,
          fontSizeFactor: 1.5
        ),
      ),
    );
  }
}
