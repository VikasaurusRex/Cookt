import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/models/User.dart';
import 'package:cookt/widgets/browse/FoodItemView.dart';
import 'package:cookt/widgets/personal/StoreOverview.dart';

import 'package:cookt/models/DatabaseIntegrator.dart';
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
    labels.insert(0, '\$${item.price.toStringAsFixed(2)}');
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
                  return FoodItemView(reference: item.reference, cook: user,);
                },
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                alignment: AlignmentDirectional.topEnd,
                children: <Widget>[
                  Stack(
                      //fit: StackFit.expand,
                    alignment: AlignmentDirectional.bottomEnd,
                    children: widget.showUser? <Widget>[
                      AspectRatio(
                        aspectRatio: 1,
                        child: DatabaseIntegrator.foodImage(item.image),
                      ),
                      InkWell(
                          onTap: (){
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return StoreOverview(user);
                                },
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              // Box decoration takes a gradient
                              gradient: LinearGradient(
                                // Where the linear gradient begins and ends
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                // Add one stop for each color. Stops should increase from 0 to 1
                                stops: [0, 1],
                                colors: [
                                  // Colors are easy thanks to Flutter's Colors class.
                                  Colors.black87,
                                  Colors.black26
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 8, 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        user.kitchenname == null?Container():Text(user.kitchenname, style: Theme.of(context).textTheme.headline.apply(fontWeightDelta: 2, color: Theme.of(context).primaryColor), textScaleFactor: 0.7,),
                                        user.about == null?Container():Container(width:150, child:Text(user.about, maxLines: 4, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.subhead.apply(color: Theme.of(context).primaryColorLight), textScaleFactor: 0.7, textAlign: TextAlign.right,),),
                                        Text('By ${user.firstname} ${user.lastname}', style: Theme.of(context).textTheme.subhead.apply(color: Theme.of(context).primaryColor), textScaleFactor: 0.7,),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: ClipRRect(
                                        borderRadius: new BorderRadius.circular(50),
                                        child: DatabaseIntegrator.userImage('usercook'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ),
                    ]:
                    <Widget>[
                      AspectRatio(
                        aspectRatio: 1,
                        child: item.image == null? Container(color: Colors.grey, child: Icon(Icons.image, color: Colors.black45,),): DatabaseIntegrator.foodImage(item.image),
                        ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: InkWell(
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: <Widget>[
                          Icon(Icons.favorite, color: item.likedBy.contains('usercustomer')?Theme.of(context).primaryColor:Colors.transparent,),
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
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('${item.name} ${item.isHosting? '':'(Not Available)'}', style: Theme.of(context).textTheme.title.apply(fontSizeFactor: 0.9),),
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
}