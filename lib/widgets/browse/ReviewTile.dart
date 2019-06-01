import 'package:flutter/material.dart';

import 'package:cookt/models/foodItems/Review.dart';
import 'package:cookt/models/DatabaseIntegrator.dart';

class ReviewTile extends StatefulWidget {
  final Review review;

  ReviewTile(this.review);

  @override
  State<StatefulWidget> createState() =>_ReviewTileState(review);
}

class _ReviewTileState extends State<ReviewTile> {
  String _name = "";

  _ReviewTileState(Review review){
    DatabaseIntegrator.nameFull(review.userid).then((val) => setState(() {
      _name = val;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(5.0)
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(_name, style: Theme.of(context).textTheme.subtitle),
                    Padding(padding: EdgeInsets.all(4.0),),
                    Row(
                      children: <Widget>[
                        Text('${widget.review.rating}', style: Theme.of(context).textTheme.subhead,),
                        Padding(padding: EdgeInsets.all(2.0),),
                        Icon(Icons.star, size: 15.0,)
                      ],
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.all(4.0),),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('${widget.review.review}', style: Theme.of(context).textTheme.subhead),
                    )
                ),
              ],
            ),
          )
      ),
    );
  }
}