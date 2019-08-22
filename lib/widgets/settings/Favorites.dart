import 'package:flutter/material.dart';

import 'package:cookt/models/foodItems/FoodItemList.dart';
import 'package:cookt/widgets/foodItems/FoodItemListView.dart';

class Favorites extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>_FavoritesState();
}

class _FavoritesState extends State<Favorites> {

  FoodItemList myList;

  void loadData() {
    myList = FoodItemList.favoritesOf(userID: 'usercustomer', complete: (){
      setState(() {});
    });
  }

  _FavoritesState() {
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites'),),
      body: ListView(
        children: <Widget>[
          FoodItemListView(myList.byFavorites('usercustomer'), myList.users, key: Key('ALL_REST')),
        ],
      ),
    );
  }
}