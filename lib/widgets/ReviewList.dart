import 'package:flutter/material.dart';

import 'package:cookt/models/foodItems/Review.dart';
import 'ReviewTile.dart';

class ReviewList extends StatefulWidget {
  List<Review> reviews;

  ReviewList(this.reviews);

  @override
  State<StatefulWidget> createState() =>_ReviewListState();
}

class _ReviewListState extends State<ReviewList> {

  @override
  Widget build(BuildContext context) {

    return widget.reviews.length<=0?
    Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
          height: 60.0,
          decoration: BoxDecoration(
          ),
          child: Center(
              child: Text('No Reviews Yet.', style: Theme.of(context).textTheme.subhead,)
          )
      ),
    )
        :
    Column(
      children: widget.reviews.map((review) => ReviewTile(review)).toList(),
    );
  }
}