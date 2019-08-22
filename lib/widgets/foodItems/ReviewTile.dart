import 'package:flutter/material.dart';

import 'package:cookt/models/foodItems/Review.dart';
import 'package:cookt/services/Services.dart';
import 'package:cookt/models/users/User.dart';

class ReviewTile extends StatefulWidget {
  final Review review;

  ReviewTile(this.review);

  @override
  State<StatefulWidget> createState() =>_ReviewTileState(review);
}

class _ReviewTileState extends State<ReviewTile> {
  User reviewer;

  _ReviewTileState(Review review){
    Services.userWithUid(review.userid).then((user){
      setState(() {
        this.reviewer = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        setState(() {

        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
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
                      reviewer!=null? Text(
                          '${reviewer.firstname} ${reviewer.lastname}',
                          style: Theme.of(context).textTheme.subhead.apply(
                            color: Theme.of(context).primaryColorDark,
                            fontWeightDelta: 2,
                          )
                      ):Container(),
                      Padding(padding: EdgeInsets.all(4.0),),
                      Row(
                        children: <Widget>[
                          Text(
                            '${widget.review.rating}',
                            style: Theme.of(context).textTheme.subhead,
                          ),
                          Padding(padding: EdgeInsets.all(2.0),),
                          Icon(Icons.star, size: 15.0,)
                        ],
                      )
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(4.0),),
                  Container(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '${widget.review.review}',
                          style: Theme.of(context).textTheme.subhead,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
}