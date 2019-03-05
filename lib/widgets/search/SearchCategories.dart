import 'package:flutter/material.dart';
import 'package:cookt/models/foodItems/FoodItem.dart';
import 'CategoryTile.dart';

class SearchHome extends StatelessWidget {

  SearchHome();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 2,
          children: FoodItem.allCategories.map((category) => CategoryTile(category)).toList(),
        ),
      ),
    );
  }
}