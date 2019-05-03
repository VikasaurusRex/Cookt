import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/properties.dart';

class FoodItem {

  static final cooktPercent = Properties.cooktPercentage;

  List<dynamic> categories;
  String description;
  bool isHosting;
  List<dynamic> likedBy;
  String name;
  int numImages;
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
    "Juice",
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
        this.numImages = 0,
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
        assert(map['numImages'] != null),
        assert(map['price'] != null),
        assert(map['timeCreated'] != null),
        assert(map['timeUpdated'] != null),
        assert(map['uid'] != null),
        this.categories = map['categories'],
        this.description = map['description'],
        this.isHosting = map['isHosting'],
        this.likedBy = map['likedBy'],
        this.name = map['name'],
        this.numImages = map['numImages'],
        this.price = map['price'].toDouble(),
        this.timeCreated = map['timeCreated'],
        this.timeUpdated = map['timeUpdated'],
        this.uid = map['uid'];

  FoodItem.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "${reference.documentID}";

  Future<DocumentReference> createListing() {
    Map<String, dynamic> map = Map();
    map['categories'] = categories;
    map['description'] = description;
    map['isHosting'] = isHosting;
    map['likedBy'] = likedBy;
    map['name'] = name;
    map['numImages'] = numImages;
    map['price'] = price;
    map['timeCreated'] = timeCreated;
    map['timeUpdated'] = timeUpdated;
    map['uid'] = uid;

    return Firestore.instance.collection('fooddata').add(map);
  }

  void updateListingWithData(DocumentReference ref) {
    Map<String, dynamic> map = Map();
    map['categories'] = categories;
    map['description'] = description;
    map['name'] = name;
    map['numImages'] = numImages;
    map['price'] = price;
    map['timeUpdated'] = DateTime.now();

    updateFields(map, ref);
  }

  void updateFields(Map<String, dynamic> map, DocumentReference ref) {
    ref.updateData(map);
  }

  bool operator ==(other) {
    return (other is FoodItem && other.reference == reference);
  }

}