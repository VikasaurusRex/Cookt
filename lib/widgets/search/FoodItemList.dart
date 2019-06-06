import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'FoodItemTile.dart';

class FoodItemList extends StatefulWidget {
  final List<Query> queries;
  final Key key;

  FoodItemList(this.queries, {@required this.key});

  @override
  State<StatefulWidget> createState() =>_FoodItemListState(queries);
}

class _FoodItemListState extends State<FoodItemList> {

  final List<Query> queries;
  List<FoodItem> items = List();

  _FoodItemListState(this.queries){
    queries.forEach((query){
      query.snapshots().listen((querySnapshot){
        querySnapshot.documents.forEach((snapshot){
          FoodItem item = FoodItem.fromSnapshot(snapshot);
          //print('  Found the snapshot ${snapshot.documentID}: ${snapshot.data}');
          if(!items.contains(item)){
            setState(() {
              if(item.isHosting)
                items.insert(0, item);
              else
                items.insert(items.length, item);
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //print('Number of orders: ${orders.length}');
    return Container(
        child: items.length>0?

        ListView(
          children: items.map((item) => FoodItemTile(item, key: Key(item.toString()),)).toList(),
        )

            :

        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.filter_none, size: 75, color: Colors.grey,),
              Padding(
                padding: EdgeInsets.all(20),
                // TODO: Change Text
                child: Text('Hmmm, couldn\'t find anything.', style: Theme.of(context).textTheme.title.apply(color: Colors.grey),),
              )
            ],
          ),
        )

    );
  }
}