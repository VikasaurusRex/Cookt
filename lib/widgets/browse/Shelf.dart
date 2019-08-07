import 'package:flutter/material.dart';

import 'package:cookt/models/User.dart';
import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/widgets/search/FoodItemTile.dart';

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
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('$title', style: Theme.of(context).textTheme.title.apply(fontWeightDelta: 1),),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 25),
              child: Container(
                  height: 363,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: items.map((item) => Container(
                      width: 300,
                      height: 275,
                      child: FoodItemTile(item, users[item.uid], true, key: Key('${item.toString()}'),),
                    )).toList(),
                  )
              ),
            )
          ]
        ):Container();
  }


}