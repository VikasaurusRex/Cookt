import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/orders/Item.dart';
import 'package:cookt/models/orders/Selection.dart';

class Order {

  // TODO: Automatically load items

  String cookID;
  String customerID;
  String lastTouchedID;
  DateTime lastTouchedTime;
  DateTime orderTime; // time of Order Creation
  DateTime pickupTime; // estimated Completion Time
  DateTime completionTime; // actual Completion Time
  String orderType;
  String status;
  double subtotalPrice;
  double taxPrice;
  double cooktPrice;
  double deliveryPrice;
  double totalPrice;
  String taxZip;
  bool active; // If false the order is either cancelled or finished.
               // If status == 'FINISHED' then its finished otherwise
               // its cancelled

  DocumentReference reference;

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
        this.subtotalPrice = -1,
        this.taxPrice = -1,
        this.cooktPrice = -1,
        this.deliveryPrice = -1,
        this.totalPrice = -1,
        this.taxZip = "00000",
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
        assert(map['subtotalPrice'] != null),
        assert(map['taxPrice'] != null),
        assert(map['cooktPrice'] != null),
        assert(map['deliveryPrice'] != null),
        assert(map['totalPrice'] != null),
        assert(map['taxZip'] != null),
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
        this.subtotalPrice = map['subtotalPrice'].toDouble(),
        this.taxPrice = map['taxPrice'].toDouble(),
        this.cooktPrice = map['cooktPrice'].toDouble(),
        this.deliveryPrice = map['deliveryPrice'].toDouble(),
        this.totalPrice = map['totalPrice'].toDouble(),
        this.taxZip = map['taxZip'],
        this.active = map['active'];

  Order.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "$cookID $customerID ${reference.documentID} $orderTime $status $lastTouchedID $active Order";

  Future<DocumentReference> create({Item item, List<Selection> selections}) async {
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
    map['subtotalPrice'] = subtotalPrice;
    map['taxPrice'] = taxPrice;
    map['cooktPrice'] = cooktPrice;
    map['deliveryPrice'] = deliveryPrice;
    map['totalPrice'] = totalPrice;
    map['taxZip'] = taxZip;
    map['active'] = active;

    Firestore.instance.collection('orders').add(map).then((ref){
      this.reference = ref;

      if(item != null){
        item.create(ref, selections: selections);
      }

      return ref;
    });
  }

  void acceptFinishOrder(){
    Map<String, dynamic> data  = Map();
    data['status'] = status==Status.accepted?Status.finished:Status.accepted;
    data['active'] = status==Status.accepted? false: true;
    data['lastTouchedID'] = 'usercook';
    data['lastTouchedTime'] = DateTime.now();

    reference.updateData(data);
  }

  void cancelOrder(){
    Map<String, dynamic> data  = Map();
    data['lastTouchedID'] = 'usercook';
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
    map['subtotalPrice'] = subtotalPrice;
    map['taxPrice'] = taxPrice;
    map['cooktPrice'] = cooktPrice;
    map['deliveryPrice'] = deliveryPrice;
    map['totalPrice'] = totalPrice;
    map['taxZip'] = taxZip;

    reference.updateData(map);
  }

  // TODO: Remove Comment
  void deleteOrder(){
    print('Deleting Order from Database');
    reference.delete();
  }

  // TODO: Implemenet items() call instead of .collection('items')
  List<Item> items(){

  }

  void addItem(Item item, List<Selection> selections){
    item.create(reference, selections: selections);
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
    map['subtotalPrice'] = -1;
    map['taxPrice'] = -1;
    map['cooktPrice'] = -1;
    map['deliveryPrice'] = -1;
    map['totalPrice'] = -1;
    map['active'] = true;
    map['taxZip'] = "00000";

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