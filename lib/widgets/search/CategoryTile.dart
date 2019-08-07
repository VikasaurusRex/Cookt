import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget{
  String category;
  VoidCallback onTileTapped;

  CategoryTile(this.category, this.onTileTapped);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: Container(

        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            new BoxShadow(
              color: Colors.black12,
              blurRadius: 2.0,
            )
          ],
        ),
        child: FlatButton(
          onPressed: onTileTapped,
          child: Text(category, style: Theme.of(context).textTheme
              .subhead.apply(fontSizeDelta: 2, fontWeightDelta: 2, color: Theme.of(context).primaryColor),),
        ),
      ),
    );
  }
}