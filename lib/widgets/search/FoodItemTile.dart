import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/models/User.dart';
import 'package:cookt/widgets/browse/FoodItemView.dart';
import 'package:cookt/models/DatabaseIntegrator.dart';
import 'InfoTiles.dart';

class FoodItemTile extends StatefulWidget {
  final FoodItem item;
  final User user;

  Key key;

  FoodItemTile(this.item, this.user, {@required this.key});

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
      child: InkWell(
        onTap: (){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return FoodItemView(reference: item.reference,);
              },
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: item.isHosting? Colors.white: Color(0xFFCBCBCB),
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1,
                      child: DatabaseIntegrator.foodImage(item.images[0]),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: InkWell(
                        child: Stack(
                          children: <Widget>[
                            Icon(Icons.favorite, color: item.likedBy.contains('usercustomer')?Colors.pinkAccent:Colors.transparent,),
                            Icon(Icons.favorite_border, color: Colors.white),
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
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('${item.name} ${item.isHosting? '':'(Not Available)'}', style: Theme.of(context).textTheme.title,),
                ),
                InfoTiles(labels, key: Key(labels.toString()),),
                Container(
                  height: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 4.0, 0, 0),
                  child: Text('Served by ${user.firstname} ${user.lastname}', style: Theme.of(context).textTheme.subtitle.apply(color: item.isHosting? Colors.grey: Colors.black),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}