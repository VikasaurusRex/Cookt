import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';

class Review {
  final int rating;
  final String review;
  final String userid;
  final DateTime time;

  final DocumentReference reference;

  Review.fromMap(Map<String, dynamic> map, {@required this.reference}) :
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

  static void createReview(String review, int rating, FoodItem foodItem) {
    Map<String, dynamic> map = Map();
    map['rating'] = rating;
    map['review'] = review;
    map['userid'] = 'usercustomer';
    map['time'] = DateTime.now();

    foodItem.reference.collection('reviews').add(map);
  }

  void updateReview(String review, int rating) {
    Map<String, dynamic> map = Map();
    map['rating'] = rating;
    map['review'] = review;
    map['time'] = DateTime.now();

    reference.updateData(map);
  }

  bool operator ==(other) {
    return (other is Review && other.reference == reference);
  }
}