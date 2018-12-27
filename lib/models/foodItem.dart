import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FoodItem {

  static final double cooktPercent = 0.05;

   List<String> categories;
   String description;
   bool dineInAvailable;
   bool isHosting;
   List<String> likedBy;
   String name;
   int numImages;
   double price;
   DateTime timeCreated;
   DateTime timeUpdated;
   final String uid;
   List<Review> reviews = []; // must be done later

  static List<String> allCategories = ["American", "Bakery", "Breakfast", "Burgers", "Chinese", "Coffee", "Dessert", "Indian", "Italian", "Juice", "Korean", "Mediterranean", "Mexican", "Pizza", "Seafood", "Thai", "Vegan", "Vegetarian"];

  DocumentReference reference;

  FoodItem.newItem():
        this.categories = [],
        this.description = '',
        this.dineInAvailable = false,
        this.isHosting = false,
        this.likedBy = [],
        this.name = '',
        this.numImages = 0,
        this.price = 0,
        this.timeCreated = DateTime.now(),
        this.timeUpdated = DateTime.now(),
        this.uid = "usercook",
        this.reference = null;



  FoodItem.fromMap(Map<String, dynamic> map, {this.reference}) :
        assert(map['categories'] != null),
        assert(map['description'] != null),
        assert(map['dineInAvailable'] != null),
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
        this.dineInAvailable = map['dineInAvailable'],
        this.isHosting = map['isHosting'],
        this.likedBy = map['likedBy'],
        this.name = map['name'],
        this.numImages = map['numImages'],
        this.price = map['price'],
        this.timeCreated = map['timeCreated'],
        this.timeUpdated = map['timeUpdated'],
        this.uid = map['uid'];

  FoodItem.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "${reference.documentID}";

  Future<DocumentReference> createListing(){
    Map<String, dynamic> map = Map();
      map['categories'] = categories;
      map['description'] = description;
      map['dineInAvailable'] = dineInAvailable;
      map['isHosting'] = isHosting;
      map['likedBy'] = likedBy;
      map['name'] = name;
      map['numImages'] = numImages;
      map['price']= price;
      map['timeCreated'] = timeCreated;
      map['timeUpdated'] = timeUpdated;
      map['uid'] = uid;

    return Firestore.instance.collection('fooddata').add(map);
  }

  void updateListingWithData(DocumentReference ref){
    Map<String, dynamic> map = Map();
    map['categories'] = categories;
    map['description'] = description;
    map['dineInAvailable'] = dineInAvailable;
    map['name'] = name;
    map['numImages'] = numImages;
    map['price']= price;
    map['timeUpdated'] = DateTime.now();

    updateFields(map, ref);
  }

   void updateFields(Map<String, dynamic> map, DocumentReference ref){
     ref.updateData(map);
   }

  bool operator ==(other) {
    return (other is FoodItem && other.reference == reference);
  }
}

class Review {
  final int rating;
  final String review;
  final String userid;
  final DateTime time;

  final DocumentReference reference;

  Review.fromMap(Map<String, dynamic> map, {this.reference}) :
        assert(map['rating'] != null),
        assert(map['review'] != null),
        assert(map['userid'] != null),
        assert(map['time'] != null),
        this.rating = map['rating'],
        this.review = map['review'],
        this.userid = map['userid'],
        this.time = map['time'];

  Review.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "$userid : $rating";
}