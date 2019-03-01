import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/orderData.dart';
import 'package:cookt/widgets/old/FoodItemEditor.dart';

class MyCart extends StatefulWidget {
  @override
  _MyCartState createState() {
    return _MyCartState();
  }
}

class _MyCartState extends State<MyCart> {
  Map<String, List<OrderData>> cartOrders = Map();
  List<Widget> cartOrderGroups = [];

  Map<String, File> foodImaged = Map();

  @override
  Widget build(BuildContext context) {

    loadCartData();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
//        leading: IconButton(
//          icon: Icon(Icons.chevron_left),
//          iconSize: 40.0,
//          onPressed: _showOldForm,
//        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16.0),
        children: cartOrderGroups.toList(),
      ),
    );
  }

  void loadCartData() async {
    await for (var snapshots in Firestore.instance
        .collection("orders")
        .where("customerID", isEqualTo: "usercustomer")
        .where("status", isEqualTo: "PENDING")
        .where("cancelled", isEqualTo: false)
        .snapshots().asBroadcastStream()) {
      for (int i = 0; i < snapshots.documentChanges.length; i++) {
        OrderData order = OrderData.fromSnapshot(snapshots.documents.elementAt(i));
        if(cartOrders[order.cookID] == null)
          cartOrders[order.cookID] = List<OrderData>();
        if (!cartOrders[order.cookID].contains(order)){
          cartOrders[order.cookID].add(order);
          makeCurrentOrders();
        }

      }
    }
  }

  void makeCurrentOrders(){
    cartOrderGroups = [];
    cartOrders.forEach((key, orders){
      if(orders.length > 0)
        cartOrderGroups.add(_orderListCell(orders));
    });
    setState(() {});
  }

  Widget _orderListCell(List<OrderData> orders) {
    List<Widget> sectionalOrders = [];
    for(OrderData order in orders){
      sectionalOrders.add(_orderCell(order));
      print("Adding ${order.reference.documentID}");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          child: orders.first.cookName(context),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
            child: Column(
              children: sectionalOrders,
            ),
          ),
        ),
      ],
    );
  }

  Widget _orderCell(OrderData order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          //borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ClipRRect(
                borderRadius: new BorderRadius.circular(5.0),
                child: order.foodImage(context),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    order.foodNameSolo(context),
                    //Padding(padding: EdgeInsets.all(4.0)),
                    //order.cookName(context),
                    Padding(padding: EdgeInsets.all(20.0)),
                    _orderOptions(context, order),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderOptions(BuildContext context, OrderData order){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(padding: EdgeInsets.all(5),),
        SizedBox(
          width: 50,
          height: 30,
          child: FlatButton(
            onPressed: (){
              setState(() {
                print(order.quantity);
                if(order.quantity > 1) {
                  order.decrementQuantity(context);
                  makeCurrentOrders();
                  return;
                }
                _confirmDelete(order);
                makeCurrentOrders();
              });
            },
            child: Icon(Icons.remove),
          ),
        ),
        Expanded(
          child: Center(
            child: Text('${order.quantity}'),
          ),
        ),
        SizedBox(
          width: 50,
          height: 30,
          child: FlatButton(
            onPressed: (){
              order.incrementQuantity();
              makeCurrentOrders();
            },
            child: Icon(Icons.add),
          ),
        ),
        Padding(padding: EdgeInsets.all(5),),
      ],
    );
  }


  void remove(OrderData order){
    cartOrders[order.cookID].remove(order);
    makeCurrentOrders();
  }

  Future<void> _confirmDelete(OrderData order) async {
    print('CONFIRM');
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to remove the order from your cart?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                order.decrementQuantity(context);
                remove(order);
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
