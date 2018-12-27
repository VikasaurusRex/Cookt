import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'newForm.dart';
import 'package:cookt/models/orderData.dart';
import 'foodIemEditor.dart';

class CurrentOrders extends StatefulWidget {
  @override
  _CurrentOrdersState createState() {
    return _CurrentOrdersState();
  }
}

class _CurrentOrdersState extends State<CurrentOrders> {
  List<OrderData> requestedOrders = [];
  List<OrderData> acceptedOrders = [];

  List<Widget> currentOrders = [];

  Map<String, File> foodImaged = Map();


  @override
  Widget build(BuildContext context) {

    Stream<String>.periodic(Duration(seconds: 3), (int numRepeats){
    }).asBroadcastStream();

    _loadRequestedData();
    _loadAcceptedData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cookt'),
//        leading: IconButton(
//          icon: Icon(Icons.chevron_left),
//          iconSize: 40.0,
//          onPressed: _showOldForm,
//        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showNewForm,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16.0),
        children: currentOrders.toList(),
      ),
    );
  }

  Future _showNewForm() async {
    // push a new route like you did in the last section
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return FoodItemEditor();
        },
      ),
    );
  }

  Future _showOldForm() async {
    print('Back');
  }

  void _loadRequestedData() async {
    await for (var snapshots in Firestore.instance
        .collection("orders")
        .where("cookID", isEqualTo: "usercook")
        .where("status", isEqualTo: "REQUESTED")
        .snapshots().asBroadcastStream()) {
      for (int i = 0; i < snapshots.documentChanges.length; i++) {

        OrderData order = OrderData.fromSnapshot(snapshots.documents.elementAt(i));
        if (!requestedOrders.contains(order)){// && (snapshots.documentChanges.elementAt(i) == DocumentChangeType.added || snapshots.documentChanges.elementAt(i) == DocumentChangeType.values)){// && (snapshot.runtimeType == DocumentChangeType.values || snapshot.runtimeType == DocumentChangeType.added)) {
          requestedOrders.add(order);
          makeCurrentOrders();
        }
      }
    }
  }

  void _loadAcceptedData() async {
    await for (QuerySnapshot snapshots in Firestore.instance
        .collection("orders")
        .where("cookID", isEqualTo: "usercook")
        .where("status", isEqualTo: "ACCEPTED")
        .snapshots().asBroadcastStream()) {
      for (int i = 0; i < snapshots.documentChanges.length; i++) {
        OrderData order = OrderData.fromSnapshot(snapshots.documents.elementAt(i));
        if (!acceptedOrders.contains(order)){// && (snapshots.documentChanges.elementAt(i) == DocumentChangeType.added || snapshots.documentChanges.elementAt(i) == DocumentChangeType.values)){// && (snapshot.runtimeType == DocumentChangeType.values || snapshot.runtimeType == DocumentChangeType.added)) {
          acceptedOrders.add(order);
          makeCurrentOrders();
        }
      }
    }
  }

  Widget _orderCell(OrderData order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: new BorderRadius.circular(10.0),
                    child: order.foodImage(context),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        order.foodName(context),
                        order.destinationOptions(context),
                        Padding(padding: EdgeInsets.all(4.0)),
                        order.pickupTimeFromNow(context),
                        Padding(padding: EdgeInsets.all(4.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${order.status.toUpperCase().substring(0, 1)}${order.status.toLowerCase().substring(1)}',
                            style: Theme.of(context).textTheme.subhead,
                          ),
                          order.customerName(context),
                        ],
                      ),
                      ],
                    ),
                  ),
                ],
              ),
              orderOptions(context, order),
            ],
          ),
        ),
      ),
    );
  }

  Widget orderOptions(BuildContext context, OrderData order){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: FlatButton(
            onPressed: (){
              _presentDialog(false, order);
            },
            splashColor: Colors.greenAccent,
            child: Text(
              order.accepted?"Finish":"Accept",
              style: Theme.of(context).textTheme.button.apply(color: Colors.green),
            ),
          ),
        ),
        Expanded(
          child: FlatButton(
            onPressed: (){
              _presentDialog(true, order);
            },
            splashColor: Colors.redAccent,
            child: Text(
              "Cancel",
              style: Theme.of(context).textTheme.button.apply(color: Colors.deepOrange),
            ),
          ),
        ),
      ],
    );
  }


  void remove(OrderData order){
    if(order.accepted){
      acceptedOrders.remove(order);
    }else{
      requestedOrders.remove(order);
    }
    makeCurrentOrders();
  }

  void makeCurrentOrders(){
    currentOrders = [];
    for(OrderData order in requestedOrders){
      currentOrders.add(_orderCell(order));
    }
    for(OrderData order in acceptedOrders){
      currentOrders.add(_orderCell(order));
    }
    setState(() {});
  }

  Future<void> _presentDialog(bool isCancelling, OrderData order) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to ${isCancelling?'cancel':order.accepted?'finish':'accept'} the order?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                remove(order);
                isCancelling?order.cancelOrder():order.acceptFinishOrder();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
