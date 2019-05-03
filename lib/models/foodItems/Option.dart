import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';

class Option {
  int maxSelection;
  List<String> options;
  List<double> price;
  String title;

  final DocumentReference reference;

  Option.fromMap(Map<String, dynamic> map, {@required this.reference}) :
        assert(map['maxSelection'] != null),
        assert(map['options'] != null),
        assert(map['price'] != null),
        assert(map['title'] != null),
        this.maxSelection = map['maxSelection'],
        this.options = map['options'],
        this.price = map['price'],
        this.title = map['title'];

  Option.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Option.newOption() :
    this.maxSelection = 0,
    this.options = ['Option Name'],
    this.price = [0.0],
    this.title = 'Selection Name',
    this.reference = null;

  @override
  String toString() => "$title : $options";

  static void createOption(String review, int rating, FoodItem foodItem) {
    Map<String, dynamic> map = Map();
    map['rating'] = rating;
    map['review'] = review;
    map['userid'] = 'usercustomer';
    map['time'] = DateTime.now();

    foodItem.reference.collection('options').add(map);
  }

  void updateReview(String review, int rating) {
    Map<String, dynamic> map = Map();
    map['rating'] = rating;
    map['review'] = review;
    map['time'] = DateTime.now();

    reference.updateData(map);
  }

  bool operator ==(other) {
    return (other is Option && other.reference == reference);
  }
}