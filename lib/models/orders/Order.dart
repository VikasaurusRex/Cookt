import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/models/orders/Item.dart';

class Order {
  String cookID;
  String customerID;
  String lastTouchedID;
  DateTime lastTouchedTime;
  DateTime orderTime; // time of Order Creation
  DateTime pickupTime; // estimated Completion Time
  DateTime completionTime; // actual Completion Time
  String orderType;
  String status;
  double deliveryPrice;
  bool active; // If false the order is either cancelled or finished.
               // If status == 'FINISHED' then its finished otherwise
               // its cancelled

  final DocumentReference reference;

  Order.newOrder(String cookID)
      :
        this.cookID = cookID,
        this.customerID = 'usercustomer',
        this.lastTouchedID = 'usercustomer',
        this.lastTouchedTime = DateTime.now(),
        this.orderTime = DateTime.now(),
        this.pickupTime = DateTime.now().add(Duration(minutes: 60-DateTime.now().minute%30)),
        this.completionTime = DateTime.fromMicrosecondsSinceEpoch(0),
        this.orderType = OrderType.pickup,
        this.status = Status.pending,
        this.deliveryPrice = 0.00,
        this.active = true,
        this.reference = null;

  Order.fromMap(Map<String, dynamic> map, {@required this.reference}) :
        assert(map['cookID'] != null),
        assert(map['customerID'] != null),
        assert(map['lastTouchedID'] != null),
        assert(map['lastTouchedTime'] != null),
        assert(map['orderTime'] != null),
        assert(map['pickupTime'] != null),
        assert(map['completionTime'] != null),
        assert(map['orderType'] != null),
        assert(map['status'] != null),
        assert(map['deliveryPrice'] != null),
        assert(map['active'] != null),
        this.cookID = map['cookID'],
        this.customerID = map['customerID'],
        this.lastTouchedID = map['lastTouchedID'],
        this.lastTouchedTime = map['lastTouchedTime'],
        this.orderTime = map['orderTime'],
        this.pickupTime = map['pickupTime'],
        this.completionTime = map['completionTime'],
        this.orderType = map['orderType'],
        this.status = map['status'],
        this.deliveryPrice = map['deliveryPrice'].toDouble(),
        this.active = map['active'];

  Order.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "$cookID $customerID ${reference.documentID} ${orderTime.millisecond} $status Order";

  void createListing() {
    Map<String, dynamic> map = Map();
    map['cookID'] = cookID;
    map['customerID'] = customerID;
    map['lastTouchedID'] = 'usercustomer';
    map['lastTouchedTime'] = DateTime.now();
    map['orderTime'] = orderTime;
    map['pickupTime'] = pickupTime;
    map['completionTime'] = completionTime;
    map['orderType'] = orderType;
    map['status'] = Status.pending;
    map['deliveryPrice'] = deliveryPrice;
    map['active'] = active;

    Firestore.instance.collection('orders').add(map);
  }

  void setDeliveryPrice(double price){
    Map<String, dynamic> map = Map();
    deliveryPrice = price;
    map['deliveryPrice'] = deliveryPrice;

    reference.updateData(map);
  }

  void acceptFinishOrder(){
    Map<String, dynamic> data  = Map();
    data['status'] = status==Status.accepted?Status.finished:Status.accepted;
    data['lastTouchedID'] = 'usercook';
    data['lastTouchedTime'] = DateTime.now();

    reference.updateData(data);
  }

  void cancelOrder(){
    Map<String, dynamic> data  = Map();
    data['lastTouchedID'] = 'usercustomer';
    data['lastTouchedTime'] = DateTime.now();
    data['active'] = false;

    reference.updateData(data);
  }

  void placeOrder(){
    Map<String, dynamic> map = Map();
    map['lastTouchedID'] = 'usercustomer';
    map['lastTouchedTime'] = DateTime.now();
    map['pickupTime'] = pickupTime;
    map['orderType'] = orderType;
    map['status'] = Status.requested;
    map['deliveryPrice'] = deliveryPrice;

    reference.updateData(map);
  }

  // TODO: Remove Comment
  void deleteOrder(){
    print('Deleting Order');
    //reference.delete();
  }

  void reorder() async {

    Map<String, dynamic> map = Map();
    map['cookID'] = cookID;
    map['customerID'] = customerID;
    map['lastTouchedID'] = 'usercustomer';
    map['lastTouchedTime'] = DateTime.now();
    map['orderTime'] = DateTime.now();
    map['pickupTime'] = DateTime.now().add(Duration(minutes: 60-DateTime.now().minute%30));
    map['completionTime'] = DateTime.fromMicrosecondsSinceEpoch(0);
    map['orderType'] = OrderType.pickup;
    map['status'] = Status.pending;
    map['deliveryPrice'] = 0.00;
    map['active'] = true;

    DocumentReference newRef = await Firestore.instance.collection('orders').add(map);

    reference.collection('items').snapshots().forEach((querySnapshot){
      querySnapshot.documents.forEach((snapshot){
        Item.fromSnapshot(snapshot).reorder(newRef);
      });
    });
  }

  void refresh(){
    Map<String, dynamic> map = Map();
    map['lastTouchedID'] = 'usercustomer';
    map['lastTouchedTime'] = DateTime.now();
    pickupTime = DateTime.now().add(Duration(minutes: 60-DateTime.now().minute%30));
    map['pickupTime'] = DateTime.now().add(Duration(minutes: 60-DateTime.now().minute%30));

    reference.updateData(map);
  }

  bool operator ==(other) {
    return (other is Order && other.reference == reference && other.status == status);
  }
}

class Status {
  static const pending = 'PENDING';
  static const requested = 'REQUESTED';
  static const accepted = 'ACCEPTED';
  static const finished = 'FINISHED';
}

class OrderType {
  static const dineIn = 'DINEIN';
  static const pickup = 'PICKUP';
  static const delivery = 'DELIVERY';
  static const postmates = 'POSTMATES';
}