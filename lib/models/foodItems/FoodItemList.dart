import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookt/models/users/User.dart';
import 'FoodItem.dart';

class FoodItemList {
  List<FoodItem> items = [];
  Map<String, User> users = Map();
  VoidCallback complete;

  FoodItemList.within({double miles, this.complete}){
    User.usersWithin(distance: miles).then((usersMap){
      users = usersMap;
      users.forEach((uid, user) {
        Firestore.instance.collection('fooddata').where('uid', isEqualTo: user.reference.documentID)
            .getDocuments().then((querySnap){
          querySnap.documents.forEach((snapshot){
            FoodItem item = FoodItem.fromSnapshot(snapshot);
            if(!items.contains(item)){
              if(item.isHosting)
                items.insert(0, item);
              else
                items.insert(items.length, item);
            }
          });
          complete();
        });
      });
    });
  }

  // TODO: Copy similar structure all over
  FoodItemList.favoritesOf({String userID, this.complete}){
    Firestore.instance.collection('fooddata').where('likedBy', arrayContains: userID).getDocuments().then((querySnap){
      items = querySnap.documents.map((doc) => FoodItem.fromSnapshot(doc)).toList();
      querySnap.documents.map((doc){
        Firestore.instance.collection('users').document(doc.data['uid']).get().then((userSnap){
          users[userSnap.documentID] = User.fromSnapshot(userSnap);
        });
      }).toList();
      complete();
    });
  }

  List<FoodItem> searchBy({@required String query}){
    if(query == ''){
      return [];
    }
    List<FoodItem> filteredItems = List();
    // Prioritize name, cook, category
    items.forEach((item){
      if(item.name.contains(query) || (isNum(query) && item.price <= double.parse(query))
          || '${users[item.uid].firstname} ${users[item.uid].lastname}'.contains(query)
          || categoryContain(item, query) || users[item.uid].kitchenname.contains(query)){
        filteredItems.add(item);
      }
    });
    return filteredItems;
  }

  List<FoodItem> byCategory({@required String category}){
    List<FoodItem> filteredItems = List();
    items.forEach((item){
      if(item.categories.contains(category)){
        filteredItems.add(item);
      }
    });
    return filteredItems;
  }

  List<FoodItem> byPrice({double above, double below}){
    List<FoodItem> filteredItems = List();
    items.forEach((item){
      if((below == null || item.price <= below) && (above == null || item.price >= above)){
        filteredItems.add(item);
      }
    });
    return filteredItems;
  }
  
  List<FoodItem> byFavorites(String uid){
    List<FoodItem> filteredItems = List();
    items.forEach((item){
      if(item.likedBy.contains(uid)){
        filteredItems.add(item);
      }
    });
    return filteredItems;
  }

  bool isNum(String text){
    try{
      var value = double.parse(text);
    } on FormatException {
      return false;
    }
    return true;
  }

  bool categoryContain(FoodItem item, String query){
    if(query.length < 3)
      return false;
    for(int i = 0; i < item.categories.length; i++){
      if(item.categories[i].contains(query)) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() => "$items";
  
  bool operator ==(other) {
    return (other is FoodItemList && other.items == items);
  }
}