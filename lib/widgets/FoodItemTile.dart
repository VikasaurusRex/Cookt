import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/models/user/User.dart';
import 'package:cookt/widgets/browse/FoodItemView.dart';
import 'package:cookt/widgets/personal/StoreOverview.dart';

import 'package:cookt/services/Services.dart';
import 'InfoTiles.dart';

class FoodItemTile extends StatefulWidget {

  // TODO: Change the tile to have more information: price, distance, categories

  final FoodItem item;
  final User user;
  final bool showUser;

  Key key;

  FoodItemTile(this.item, this.user, this.showUser, {@required this.key});

  @override
  State<StatefulWidget> createState() =>_FoodItemTileState(item, user);
}

class _FoodItemTileState extends State<FoodItemTile>{
  final FoodItem item;
  User user;
  List<String> labels;

  _FoodItemTileState(this.item, this.user){
    if(user == null){
      user = User.newUser('', '', '');
      Firestore.instance.collection('users').document(item.uid).get().then((snap){
        setState(() {
          user = User.fromSnapshot(snap);
        });
      });
    }
    labels =List<String>.from(item.categories);
    //labels.insert(0, '\$${item.price.toStringAsFixed(2)}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
//          borderRadius: BorderRadius.only(
//            topLeft: Radius.circular(15.0),
//            topRight: Radius.circular(15.0)
//          ),
          boxShadow: [
            new BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
            )
          ],
          color: item.isHosting? Theme.of(context).cardColor: Theme.of(context).disabledColor,

        ),
        child: InkWell(
          onTap: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return FoodItemView(reference: item.reference, cook: user);
                },
              ),
            );
          },
          child: Column(
            children: <Widget>[
              Stack(
                alignment: AlignmentDirectional.topEnd,
                children: <Widget>[
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 1,
                        child: Services.foodImage(item.image),
                      ),
                      widget.showUser?_userTile():Container(),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: InkWell(
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                          Icon(Icons.favorite, color: item.likedBy.contains('usercustomer')?Theme.of(context).primaryColorLight:Colors.transparent,),
                          Icon(Icons.favorite_border, color: Theme.of(context).primaryColor),
                        ],
                      ),
                      onTap: (){
                        setState(() {
                          item.toggleFavorite('usercustomer');
                        });
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('${item.name} ${item.isHosting? '':'(Not Available)'}', style: Theme.of(context).textTheme.title.apply(fontSizeFactor: 0.9),),
                          Text('\$${item.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.title.apply(fontSizeFactor: 0.9),),
                        ],
                      ),
                    ),
                    InfoTiles(labels, key: Key(labels.toString()),),
                  ],
                ),
              )
            ],
          ),
        )
      )
    );
  }

  Widget _userTile(){
    return user != null? Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          // Add one stop for each color. Stops should increase from 0 to 1
          stops: [0.1, 0.5],
          colors: [
            // Colors are easy thanks to Flutter's Colors class.
            Colors.black87,
            Colors.black45
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: InkWell(
          onTap: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return StoreOverview(user);
                },
              ),
            );
          },
          child: Row( // here
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 8, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        user.kitchenname == null?Container():
                        Text(
                          user.kitchenname,
                          style: Theme.of(context).textTheme.subhead.apply(
                            fontWeightDelta: 3,
                            fontSizeFactor: 1.2,
                            color: Theme.of(context).primaryColorDark.withAlpha(200),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        user.about == null?Container():
                        Text(
                          'By ${user.firstname} ${user.lastname}',
                          style: Theme.of(context).textTheme.subhead.apply(
                            color: Theme.of(context).primaryColorLight.withAlpha(100),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(750),
                ),
                child: ClipRRect(
                  borderRadius: new BorderRadius.circular(750),
                  child: Services.userImage('usercook'),
                ),
              ),
            ],
          ),
        ),
      ),
    ):Container();
  }
}