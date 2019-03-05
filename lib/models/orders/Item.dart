import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/orders/Order.dart';
import 'package:cookt/models/orders/Selection.dart';

class Item {
  final String foodID;
  bool prepared;
  double price;
  int quantity;

  DocumentReference reference;

  Item.fromMap(Map<String, dynamic> map, {@required this.reference}) :
        assert(map['foodID'] != null),
        assert(map['prepared'] != null),
        assert(map['price'] != null),
        assert(map['quantity'] != null),
        this.foodID = map['foodID'],
        this.prepared = map['prepared'],
        this.price = map['price'],
        this.quantity = map['quantity'];

  Item.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Item.fromData(String foodID, double price, int quantity, Order order) :
        this.foodID = foodID,
        this.prepared = false,
        this.price = price,
        this.quantity = quantity,
        this.reference = null;

  @override
  String toString() => "$foodID Item";

  List<Selection> selections() {
    reference.collection('selections').snapshots().single.then(((snapshot){
      return snapshot.documents.map((document) => Selection.fromSnapshot(document)).toList();
    }));
  }

  void updateItem(String review, int rating) {
    Map<String, dynamic> map = Map();
    map['foodID'] = foodID;
    map['prepared'] = prepared;
    map['price'] = price;
    map['quantity'] = quantity;

    reference.updateData(map);
  }

  bool operator ==(other) {
    return (other is Item && other.reference == reference);
  }
}