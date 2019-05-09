import 'package:flutter/material.dart';
import 'dart:io';

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
        this.options = List<String>.from(map['options']),
        this.price = List<double>.from(List<dynamic>.from(map['price']).map((dbl) => dbl.toDouble()).toList()),
        this.title = map['title'];

  Option.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Option.newOption() :
    this.maxSelection = 3,
    this.options = ['Option 1', 'Option 2'],
    this.price = [0.0, 0.0],
    this.title = 'Option Title',
    this.reference = null;

  @override
  String toString() => "$title : $options";

  void createOption(CollectionReference ref) {
    Map<String, dynamic> map = Map();
    map['maxSelection'] = maxSelection;
    map['options'] = options;
    map['price'] = price;
    map['title'] = title;

    ref.add(map);
  }

  void updateOption() {
    Map<String, dynamic> map = Map();
    map['maxSelection'] = maxSelection;
    map['options'] = options;
    map['price'] = price;
    map['title'] = title;

    reference.updateData(map);
  }

  void deleteOption(){
    if(reference == null)
      return;
    reference.delete();
  }

  bool operator ==(other) {
    return (other is Option && other.reference == reference);
  }
}