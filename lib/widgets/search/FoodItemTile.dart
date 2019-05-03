import 'package:flutter/material.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/models/DatabaseIntegrator.dart';
import 'InfoTiles.dart';

class FoodItemTile extends StatefulWidget {
  final FoodItem item;

  Key key;

  FoodItemTile(this.item, {@required this.key});

  @override
  State<StatefulWidget> createState() =>_FoodItemTileState(item);
}

class _FoodItemTileState extends State<FoodItemTile> {
  final FoodItem item;
  String _cookName = '';

  List<dynamic> labels;

  void loadData(){
    labels =List<dynamic>.from(item.categories);
    labels.insert(0, '\$${item.price.toStringAsFixed(2)}');

    DataFetcher.nameFull(item.uid).then((name) => setState(() {
      _cookName = name;
    }));
  }

  _FoodItemTileState(this.item){
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    //print('  Number of items in order: ${items.length}');
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 2,
                child: DataFetcher.foodImage(item.reference.documentID),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(item.name, style: Theme.of(context).textTheme.title,),
              ),
              InfoTiles(labels, key: Key(labels.toString()),),
              Container(
                height: 1,
                color: Colors.grey,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 4.0, 0, 0),
                child: Text('Served by ${_cookName}', style: Theme.of(context).textTheme.subtitle.apply(color: Colors.grey),),
              )
            ],
          ),
        ),
      ),
    );
  }
}