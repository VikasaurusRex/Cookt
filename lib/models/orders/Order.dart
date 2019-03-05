import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/models/orders/Item.dart';

class Order {
  String cookID;
  String customerID;
  String lastTouchedID;
  DateTime lastTouchedTime;
  DateTime orderTime;
  DateTime pickupTime;
  String orderType;
  String status;

  final DocumentReference reference;

  Order.newOrder(String cookID)
      :
        this.cookID = cookID,
        this.customerID = 'usercustomer',
        this.lastTouchedID = 'usercustomer',
        this.lastTouchedTime = DateTime.now(),
        this.orderTime = DateTime.now(),
        this.pickupTime = DateTime.now().add(Duration(minutes: 60-DateTime.now().minute%30)),
        this.orderType = 'PICKUP',
        this.status = 'REQUESTED',
        this.reference = null;

  Order.fromMap(Map<String, dynamic> map, {@required this.reference}) :
        assert(map['cookID'] != null),
        assert(map['customerID'] != null),
        assert(map['lastTouchedID'] != null),
        assert(map['lastTouchedTime'] != null),
        assert(map['orderTime'] != null),
        assert(map['pickupTime'] != null),
        assert(map['orderType'] != null),
        assert(map['status'] != null),
        this.cookID = map['cookID'],
        this.customerID = map['customerID'],
        this.lastTouchedID = map['lastTouchedID'],
        this.lastTouchedTime = map['lastTouchedTime'],
        this.orderTime = map['orderTime'],
        this.pickupTime = map['pickupTime'],
        this.orderType = map['orderType'],
        this.status = map['status'];

  Order.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "${reference!=null?reference.documentID:"NULL"}";

//  Widget pickupTimeFromNow(BuildContext context){
//    return StreamBuilder<String>(
//      stream: Stream<String>.periodic(
//        Duration(seconds: 1), (int numRepeats) {
//          final remaining = pickupTime.difference(DateTime.now());
//
//          if(remaining.isNegative){
//            return "ASAP";
//          }
//
//          final hours = remaining.inHours - remaining.inDays * 24;
//          final minutes = remaining.inMinutes - remaining.inHours * 60;
//          final seconds = remaining.inSeconds - remaining.inMinutes * 60;
//
//          final formattedRemaining = 'In $hours hours, $minutes minutes';
//          return formattedRemaining;
//        }
//      ).asBroadcastStream(),
//    builder: (BuildContext context, AsyncSnapshot<String> text) => Text(
//      "${text.data}",
//      style: Theme.of(context).textTheme.subhead,
//    ),
//    );
//  }
//
//  Widget destinationOptions(BuildContext context){
//    if(postmatesOrder){
//      return Text(
//        "For Delivery",
//        style: Theme.of(context).textTheme.title,
//      );
//    }
//    if(dineIn){
//      return Text(
//        "For Dine In",
//        style: Theme.of(context).textTheme.title,
//      );
//    }
//    return Text(
//      "For Pickup",
//      style: Theme.of(context).textTheme.title,
//    );
//  }

  void createListing() {
    Map<String, dynamic> map = Map();
    map['cookID'] = cookID;
    map['customerID'] = customerID;
    map['lastTouchedID'] = 'usercustomer';
    map['lastTouchedTime'] = DateTime.now();
    map['orderTime'] = orderTime;
    map['pickupTime'] = pickupTime;
    map['orderType'] = orderType;
    map['status'] = 'PENDING';

    Firestore.instance.collection('orders').add(map);
  }

//  void acceptFinishOrder(){
//    Map<String, dynamic> data  = Map();
//    data['status'] = status=='ACCEPTED'?'FINISHED':'ACCEPTED';
//    data['lastTouchedID'] = 'usercook';
//    data['lastTouchedTime'] = DateTime.now();
//    reference.updateData(data);
//  }
//
//  void cancelOrder(){
//    Map<String, dynamic> data  = Map();
//    data['cancelled'] = true;
//    data['lastTouchedID'] = 'usercustomer';
//    data['lastTouchedTime'] = DateTime.now();
//    reference.updateData(data);
//  }

//  void incrementQuantity(){
//    Map<String, dynamic> data  = Map();
//    quantity++;
//    data['quantity'] = quantity;
//    data['lastTouchedID'] = 'usercustomer';
//    data['lastTouchedTime'] = DateTime.now();
//    reference.updateData(data);
//  }
//
//  void decrementQuantity(BuildContext context){
//    Map<String, dynamic> data  = Map();
//    if(quantity <= 1){
//      reference.delete();
//      return;
//    }
//    quantity--;
//    data['quantity'] = quantity;
//    data['lastTouchedID'] = 'usercook';
//    data['lastTouchedTime'] = DateTime.now();
//    reference.updateData(data);
//  }

  List<Item> selections() {
    reference.collection('items').snapshots().single.then(((snapshot){
      return snapshot.documents.map((document) => Item.fromSnapshot(document)).toList();
    }));
  }

  bool operator ==(other) {
    return (other is Order && other.reference == reference);
  }
}