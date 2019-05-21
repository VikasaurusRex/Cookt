import 'package:flutter/material.dart';


class CategoryTile extends StatelessWidget{
  String category;
  VoidCallback onTileTapped;

  CategoryTile(this.category, this.onTileTapped);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).primaryColorDark.withAlpha(230),
        ),
        child: FlatButton(
          onPressed: onTileTapped,
          child: Text(category, style: Theme.of(context).textTheme.subhead.apply(color: Colors.white),),
        ),
      ),
    );
  }
}