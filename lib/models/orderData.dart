import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'foodItem.dart';

class OrderData {
  bool accepted;
  String cookID;//
  String customerID;//
  bool dineIn;//
  String foodId;//
  String lastTouchedID;
  DateTime lastTouchedTime;
  DateTime orderTime;
  DateTime pickupTime;//
  bool postmatesOrder;//
  int quantity;//
  String status;

  final DocumentReference reference;

  OrderData.newItem(FoodItem item)
      :
        this.accepted = false,
        this.cookID = item.uid,
        this.customerID = 'usercustomer',
        this.dineIn = false,
        this.foodId = item.reference.documentID,
        this.lastTouchedID = 'usercustomer',
        this.lastTouchedTime = DateTime.now(),
        this.orderTime = DateTime.now(),
        this.pickupTime = DateTime.now().add(Duration(minutes: 60-DateTime.now().minute%30)),
        this.postmatesOrder = false,
        this.quantity = 1,
        this.status = 'REQUESTED',
        this.reference = null;

  OrderData.fromMap(Map<String, dynamic> map, {this.reference}) :
        assert(map['accepted'] != null),
        assert(map['cookID'] != null),
        assert(map['customerID'] != null),
        assert(map['dineIn'] != null),
        assert(map['foodId'] != null),
        assert(map['lastTouchedID'] != null),
        assert(map['lastTouchedTime'] != null),
        assert(map['orderTime'] != null),
        assert(map['pickupTime'] != null),
        assert(map['postmatesOrder'] != null),
        assert(map['quantity'] != null),
        assert(map['status'] != null),
        this.accepted = map['accepted'],
        this.cookID = map['cookID'],
        this.customerID = map['customerID'],
        this.dineIn = map['dineIn'],
        this.foodId = map['foodId'],
        this.lastTouchedID = map['lastTouchedID'],
        this.lastTouchedTime = map['lastTouchedTime'],
        this.orderTime = map['orderTime'],
        this.pickupTime = map['pickupTime'],
        this.postmatesOrder = map['postmatesOrder'],
        this.quantity = map['quantity'],
        this.status = map['status'];

  OrderData.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "${reference!=null?reference.documentID:"NULL"}";

  Widget customerName(BuildContext context){
    return StreamBuilder<Event>(
      stream: FirebaseDatabase.instance.reference().child(customerID).child('userinfo').onValue.asBroadcastStream(),
      builder: (context, event) {
        if (!event.hasData) return LinearProgressIndicator();
        return Text(
          'For ${event.data.snapshot.value['firstname']} ${event.data.snapshot.value['lastname'].toString().substring(0,1)}.',
          style: Theme.of(context).textTheme.subhead,
        );
      },
    );
  }

  Widget cookName(BuildContext context){
    return StreamBuilder<Event>(
      stream: FirebaseDatabase.instance.reference().child(cookID).child('userinfo').onValue.asBroadcastStream(),
      builder: (context, event) {
        if (!event.hasData) return LinearProgressIndicator();
        return Text(
          '${event.data.snapshot.value['firstname']} ${event.data.snapshot.value['lastname'].toString().substring(0,1)}.',
          style: Theme.of(context).textTheme.subhead,
        );
      },
    );
  }

  Widget foodName(BuildContext context){
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('fooddata').document(foodId).snapshots().asBroadcastStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return Text(
          '${quantity}x ${snapshot.data['name']}',
          style: Theme.of(context).textTheme.title,
        );
      },
    );
  }

  Widget foodImage(BuildContext context) {
    return FutureBuilder(
      future: FirebaseStorage.instance.ref().child("images").child("$foodId-0.png").getDownloadURL(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> imageData) {
        return Image.network(
          imageData.data.toString(),
          height: 100.0,
          width: 100.0,
          fit: BoxFit.cover,
        );
      }
    );
  }

  Widget pickupTimeFromNow(BuildContext context){
    return StreamBuilder<String>(
      stream: Stream<String>.periodic(
        Duration(seconds: 1), (int numRepeats) {
          final remaining = pickupTime.difference(DateTime.now());

          if(remaining.isNegative){
            return "ASAP";
          }

          final hours = remaining.inHours - remaining.inDays * 24;
          final minutes = remaining.inMinutes - remaining.inHours * 60;
          final seconds = remaining.inSeconds - remaining.inMinutes * 60;

          final formattedRemaining = 'In $hours hours, $minutes minutes';
          return formattedRemaining;
        }
      ).asBroadcastStream(),
    builder: (BuildContext context, AsyncSnapshot<String> text) => Text(
      "${text.data}",
      style: Theme.of(context).textTheme.subhead,
    ),
    );
  }

  Widget destinationOptions(BuildContext context){
    if(postmatesOrder){
      return Text(
        "For Delivery",
        style: Theme.of(context).textTheme.title,
      );
    }
    if(dineIn){
      return Text(
        "For Dine In",
        style: Theme.of(context).textTheme.title,
      );
    }
    return Text(
      "For Pickup",
      style: Theme.of(context).textTheme.title,
    );
  }

  void createListing() {
    Map<String, dynamic> map = Map();
    map['accepted'] = accepted;
    map['cookID'] = cookID;
    map['customerID'] = customerID;
    map['dineIn'] = dineIn;
    map['foodId'] = foodId;
    map['lastTouchedID'] = lastTouchedID;
    map['lastTouchedTime'] = DateTime.now();
    map['orderTime'] = DateTime.now();
    map['pickupTime'] = pickupTime;
    map['postmatesOrder'] = postmatesOrder;
    map['quantity'] = quantity;
    map['status'] = 'REQUESTED';

    Firestore.instance.collection('orders').add(map);
  }

  void acceptFinishOrder(){
    Map<String, dynamic> data  = Map();
    data['status'] = accepted?'FINISHED':'ACCEPTED';
    data['accepted'] = true; // Either accepting or finishing
    data['lastTouchedID'] = 'usercook';
    data['lastTouchedTime'] = DateTime.now();
    reference.updateData(data);
  }

  void cancelOrder(){
    Map<String, dynamic> data  = Map();
    data['status'] = 'CANCELLED';
    data['lastTouchedID'] = 'usercook';
    data['lastTouchedTime'] = DateTime.now();
    reference.updateData(data);
  }

  bool operator ==(other) {
    return (other is OrderData && other.reference == reference);
  }
}