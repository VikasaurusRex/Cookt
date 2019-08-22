import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:core';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/models/foodItems/FoodItemList.dart';
import 'package:cookt/widgets/foodItems/Shelf.dart';
import 'package:cookt/widgets/foodItems/FoodItemListView.dart';


class Browse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>_BrowseState();
}

class _BrowseState extends State<Browse> {

  // TODO: Fix the shelves. the rounded square look mismatched
  // TODO: Give everything space. Give large boundry, look at postmates

  FoodItemList myList;
  List<String> shelfLabels;
  List<List<FoodItem>> shelfContents;
  List<int> shelfIndeces;
  int maxShelves = 10;

  void loadData() {
      myList = FoodItemList.within(miles: 5, complete: (){
        setState(() {
          // TODO: Set bool loaded = true
          // TODO: Make flashy dummy shelves and dummy FoodItemListViews with grey swipeys

          shelfLabels.addAll(FoodItem.allCategories);
          shelfLabels.addAll(['Cheap Bites (\$)', 'Affordable Meals (\$\$)', 'Fancier Cuisine (\$\$\$)']);
          // Set all shelves possible.
          // All categories, price

          shelfContents.addAll(FoodItem.allCategories.map((cat) => myList.byCategory(category: cat)).toList());
          shelfContents.addAll([
            myList.byPrice(below: 8),
            myList.byPrice(above: 8, below: 15),
            myList.byPrice(above: 15)
          ]);


          Random rng = Random();

          for(int i = 0; i < maxShelves; i++){
            int ind = rng.nextInt(shelfLabels.length);
            while(shelfIndeces.contains(ind))
              ind = rng.nextInt(shelfLabels.length);
            shelfIndeces.add(ind);
          }
          shelfIndeces.map((ind){print('${shelfLabels[ind]}');});
        });
      });
  }

  _BrowseState() {
    loadData();
    shelfIndeces = [];
    shelfLabels = [];
    shelfContents = [];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
          child: Text('Favorites', style: Theme.of(context).textTheme.title.apply(fontWeightDelta: 1, fontSizeFactor: 1.5, color: Theme.of(context).primaryColorDark),),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: shelfIndeces.map((ind) => Shelf(shelfLabels[ind], shelfContents[ind], myList.users, key: Key('${shelfLabels[ind]} ${DateTime.now()}'))).toList(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
          child: Text('More Options', style: Theme.of(context).textTheme.title.apply(fontWeightDelta: 1, fontSizeFactor: 1.5, color: Theme.of(context).primaryColorDark),),
        ),
        FoodItemListView(myList.items, myList.users, key: Key('ALL_REST')),
      ],
    );
  }
}