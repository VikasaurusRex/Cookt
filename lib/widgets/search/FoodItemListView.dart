import 'package:flutter/material.dart';

import 'package:cookt/models/User.dart';
import 'package:cookt/models/foodItems/FoodItem.dart';
import 'FoodItemTile.dart';

class FoodItemListView extends StatelessWidget {
  final List<FoodItem> items;
  final Map<String, User> users;
  final Key key;

  FoodItemListView(this.items, this.users, {@required this.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: items.length>0?

        Column(
          children: items.map((item) => FoodItemTile(item, users[item.uid], key: Key(item.toString()),)).toList(),
        )

            :

        Padding(
          padding: EdgeInsets.all(20),
          child: Center(
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
          ),
        )

    );
  }
}