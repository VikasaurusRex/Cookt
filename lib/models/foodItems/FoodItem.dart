import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/Option.dart';

class FoodItem {

  // TODO: Automatically load reviews and options on load.

  List<String> categories;
  String description;
  bool isHosting;
  List<String> likedBy;
  String name;
  List<String> images;
  double price;
  DateTime timeCreated;
  DateTime timeUpdated;
  final String uid;

  static List<String> allCategories = [
    "American",
    "Bakery",
    "Breakfast",
    "Burgers",
    "Chinese",
    "Coffee",
    "Dessert",
    "Indian",
    "Italian",
    "Juice", // TODO: Change to beverages
    "Korean",
    "Mediterranean",
    "Mexican",
    "Pizza",
    "Seafood",
    "Thai",
    "Vegan",
    "Vegetarian"
  ];

  DocumentReference reference;

  FoodItem.newItem()
      :
        this.categories = [],
        this.description = '',
        this.isHosting = false,
        this.likedBy = [],
        this.name = '',
        this.images = [],
        this.price = 0,
        this.timeCreated = DateTime.now(),
        this.timeUpdated = DateTime.now(),
        this.uid = "usercook",
        this.reference = null;


  FoodItem.fromMap(Map<String, dynamic> map, {@required this.reference})
      :
        assert(map['categories'] != null),
        assert(map['description'] != null),
        assert(map['isHosting'] != null),
        assert(map['likedBy'] != null),
        assert(map['name'] != null),
        assert(map['price'] != null),
        assert(map['timeCreated'] != null),
        assert(map['timeUpdated'] != null),
        assert(map['uid'] != null),
        this.categories = List<String>.from(map['categories']),
        this.description = map['description'],
        this.isHosting = map['isHosting'],
        this.likedBy = List<String>.from(map['likedBy']),
        this.name = map['name'],
        this.images = List<String>.from(map['images']),
        this.price = map['price'].toDouble(),
        this.timeCreated = map['timeCreated'],
        this.timeUpdated = map['timeUpdated'],
        this.uid = map['uid'];

  FoodItem.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "${reference.documentID}";

  Future<DocumentReference> create({List<Option> options}) {
    Map<String, dynamic> map = Map();
    map['categories'] = categories;
    map['description'] = description;
    map['isHosting'] = isHosting;
    map['likedBy'] = likedBy;
    map['name'] = name;
    map['images'] = images;
    map['price'] = price;
    map['timeCreated'] = timeCreated;
    map['timeUpdated'] = timeUpdated;
    map['uid'] = uid;

    Firestore.instance.collection('fooddata').add(map).then((ref){
      this.reference = ref;

      if(options != null) {
        options.forEach((selection) {
          selection.create(ref);
        });
      }

      return ref;
    });
  }

  void updateListingWithData(DocumentReference ref) {
    Map<String, dynamic> map = Map();
    if(price < 0){
      price = 0;
    }
    map['categories'] = categories;
    map['description'] = description;
    map['name'] = name;
    map['images'] = images;
    map['price'] = price;
    map['timeUpdated'] = DateTime.now();

    ref.updateData(map);
  }
  
  void toggleFavorite(String uid){
    if(likedBy.contains(uid))
      likedBy.remove(uid);
    else
      likedBy.add(uid);

    Map<String, dynamic> map = Map();
    map['likedBy'] = likedBy;

    reference.updateData(map);
  }

  bool operator ==(other) {
    return (other is FoodItem && other.reference == reference);
  }

}