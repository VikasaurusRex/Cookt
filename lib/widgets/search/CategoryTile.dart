import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget{
  String category;

  CategoryTile(this.category);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
        color: Theme.of(context).primaryColorDark,
        child: FlatButton(
          onPressed: navigateToCategorySearch,
          child: Text(category, style: Theme.of(context).textTheme.subhead.apply(color: Colors.white),),
        ),
      ),
    );
  }

  void navigateToCategorySearch(){
    print(category);
  }
}