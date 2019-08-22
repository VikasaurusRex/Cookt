import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/orders/Order.dart';
import 'package:cookt/widgets/orders/OrderTile.dart';

class OrderList extends StatefulWidget {
  final Query query;
  final String listLabel;

  OrderList(this.query, this.listLabel);

  @override
  State<StatefulWidget> createState() =>_OrderListState(query);
}

class _OrderListState extends State<OrderList> with AutomaticKeepAliveClientMixin<OrderList> {

  final Query query;
  List<Order> orders = List();

  _OrderListState(this.query){
    query.snapshots().listen((querySnapshot) {
      setState(() {
        orders = querySnapshot.documents.map((snapshot) => Order.fromSnapshot(snapshot)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: orders.length>0?

      ListView(
        children: orders.map((order) => OrderTile(order, deleteOrder, placeOrder, cancelOrder, reorder, key: Key(order.toString()),)).toList(),
      )

          :

      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.receipt, size: 75, color: Colors.grey,),
          Padding(
            padding: EdgeInsets.all(20),
            child: Text('No ${widget.listLabel} Orders', style: Theme.of(context).textTheme.title.apply(color: Colors.grey),),
          )
        ],
      )

    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> deleteOrder(Order order) async {
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
                order.deleteOrder();
                setState(() {
                  orders.remove(order);
                });
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

  Future<void> placeOrder(Order order) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to place the order?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                order.placeOrder();
                setState(() {
                  orders.remove(order);
                });
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

  Future<void> cancelOrder(Order order) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to cancel the outstanding order?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                order.cancelOrder();
                setState(() {
                  orders.remove(order);
                });
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

  Future<void> reorder(Order order) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to reorder this order?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                order.reorder();
                Navigator.of(context).pop();
                confirmReorder();
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

  Future<void> confirmReorder() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reorder successful'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your reorder has been created.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}