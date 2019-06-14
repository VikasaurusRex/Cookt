import 'package:flutter/material.dart';

import 'package:cookt/models/User.dart';
import 'package:cookt/models/foodItems/FoodItem.dart';
import 'ShelfTile.dart';

class Shelf extends StatelessWidget {
  final String title;
  final List<FoodItem> items;
  final Map<String, User> users;
  final Key key;

  Shelf(this.title, this.items, this.users, {@required this.key});

  @override
  Widget build(BuildContext context) {
    //print('Number of orders: ${orders.length}');

    return

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('$title', style: Theme.of(context).textTheme.title.apply(fontWeightDelta: 1),),
            ),
            items.length > 0? Container(
                height: 185,
                child:
                ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: items.map((item) => Container(
                    width: 300,
                    child: ShelfTile(item, users[item.uid], key: Key(item.toString()),),
                  )).toList(),
                )
            )

                :

            Padding(
              padding: EdgeInsets.all(20),
              // TODO: Change Text
              child: Text('No Items.', style: Theme.of(context).textTheme.title.apply(color: Colors.grey),),
            ),
          ]
        );

  }


}