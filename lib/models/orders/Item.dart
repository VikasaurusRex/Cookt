import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/orders/Order.dart';
import 'package:cookt/models/orders/Selection.dart';

class Item {
  final String foodID;
  bool prepared; // TODO: Implement prepared
  double price;
  int quantity; // TODO: Implement Quantity on OrderTiles in Home and in FoodItemView

  DocumentReference reference;

  Item.fromMap(Map<String, dynamic> map, {@required this.reference}) :
        assert(map['foodID'] != null),
        assert(map['prepared'] != null),
        assert(map['price'] != null),
        assert(map['quantity'] != null),
        this.foodID = map['foodID'],
        this.prepared = map['prepared'],
        this.price = map['price'].toDouble(),
        this.quantity = map['quantity'];

  Item.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Item.from(String foodID, double price, int quantity) :
        this.foodID = foodID,
        this.prepared = false,
        this.price = price,
        this.quantity = quantity,
        this.reference = null;

  @override
  String toString() => "$foodID $quantity $price Item";

  // TODO: Implemenet items() call instead of .collection('selections')
  List<Selection> selections() {
    reference.collection('selections').snapshots().single.then(((snapshot){
      return snapshot.documents.map((document) => Selection.fromSnapshot(document)).toList();
    }));
  }

  Future<DocumentReference> create(DocumentReference reference, {List<Selection> selections}) async {
    Map<String, dynamic> map = Map();
    map['foodID'] = foodID;
    map['prepared'] = prepared;
    map['price'] = price;
    map['quantity'] = quantity;

    reference.collection('items').add(map).then((ref){
      this.reference = ref;

      if(selections != null) {
        selections.forEach((selection) {
          if(selection.selections.length > 0)
            selection.create(ref);
        });
      }

      return ref;
    });
  }

  void updateItem() {
    Map<String, dynamic> map = Map();
    map['foodID'] = foodID;
    map['prepared'] = prepared;
    map['price'] = price;
    map['quantity'] = quantity;

    reference.updateData(map);
  }

  void incrementQuantity(){
    Map<String, dynamic> data  = Map();
    quantity++;
    data['quantity'] = quantity;
    data['lastTouchedID'] = 'usercustomer';
    data['lastTouchedTime'] = DateTime.now();
    reference.updateData(data);
  }

  void decrementQuantity(BuildContext context){
    Map<String, dynamic> data  = Map();
    if(quantity <= 1){
      //reference.delete();
      print('Deleting Item');
      return;
    }
    quantity--;
    data['quantity'] = quantity;
    data['lastTouchedID'] = 'usercook';
    data['lastTouchedTime'] = DateTime.now();
    reference.updateData(data);
  }

  void toggleItemPrepared(){
    prepared = !prepared;
    Map<String, dynamic> data  = Map();
    data['prepared'] = prepared;
    reference.updateData(data);
  }

  void deleteItem(){
    print('Deleting Item');
    //reference.delete();
  }
  
  void reorder(DocumentReference ref) async {
    Map<String, dynamic> map = Map();
    map['foodID'] = foodID;
    map['prepared'] = prepared;
    map['price'] = price;
    map['quantity'] = quantity;

    DocumentReference newRef = await ref.collection('items').add(map);

    reference.collection('selections').snapshots().forEach((querySnapshot){
      querySnapshot.documents.forEach((snapshot){
        Selection.fromSnapshot(snapshot).reorder(newRef);
      });
    });
  }

  bool operator ==(other) {
    return (other is Item && other.reference == reference && other.price == price && other.quantity == quantity);
  }
}