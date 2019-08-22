import 'package:flutter/material.dart';

import 'package:cookt/models/users/User.dart';
import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/widgets/foodItems/FoodItemTile.dart';

class Shelf extends StatelessWidget {
  final String title;
  final List<FoodItem> items;
  final Map<String, User> users;
  final Key key;

  Shelf(this.title, this.items, this.users, {@required this.key});

  @override
  Widget build(BuildContext context) {
    return

      items.length > 0? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
              child: Text('$title', style: Theme.of(context).textTheme.title.apply(fontWeightDelta: 1),),
            ),
            Padding(
              padding: EdgeInsets.all(4),
              child: Container(
                  height: 375,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: items.map((item) => Container(
                      width: 300,
                      child: FoodItemTile(item, users[item.uid], false, key: Key('${item.toString()}'),),
                    )).toList(),
                  )
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), child: Container(height: 1, color: Colors.black12,),)
          ]
        ):Container();
  }


}