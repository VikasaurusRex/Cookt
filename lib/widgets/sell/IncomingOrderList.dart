import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/orders/Order.dart';
import 'package:cookt/services/PaymentService.dart';
import 'package:cookt/widgets/sell/IncomingOrderTile.dart';

class IncomingOrderList extends StatefulWidget {
  final List<Query> queries;

  IncomingOrderList(this.queries);

  @override
  State<StatefulWidget> createState() =>_IncomingOrderListState(queries);
}

class _IncomingOrderListState extends State<IncomingOrderList>  with AutomaticKeepAliveClientMixin<IncomingOrderList> {

  final List<Query> queries;
  List<Order> orders = List();
  int numRequested = 0;

  _IncomingOrderListState(this.queries){
    queries.forEach((query){
      query.snapshots().listen((querySnapshot) {
        querySnapshot.documents.forEach((snapshot){
          Order order = Order.fromSnapshot(snapshot);
          //print('  Found the snapshot ${snapshot.documentID}: ${snapshot.data}');
          if(!orders.contains(order)){
            setState(() {
              orders.add(order);
            });
          }else{
            int index = orders.indexOf(order);
            setState(() {
              orders.removeAt(index);
            });
            setState(() {
              orders.insert(index, order);
            });
          }
        });
      });
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: orders.length>0?

        ListView(
          children: orders.map((order) => IncomingOrderTile(order, acceptFinishOrder, cancelOrder, key: Key(order.toString()),)).toList(),
        )

            :

        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.receipt, size: 75, color: Colors.grey,),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text('No Incoming Orders Yet...', style: Theme.of(context).textTheme.title.apply(color: Colors.grey),textAlign: TextAlign.center,),
            )
          ],
        )

    );
  }

  Future<void> acceptFinishOrder(Order order) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to ${order.status == Status.accepted?'finish': 'accept'} the order?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                if(order.status == Status.accepted)
                  PaymentService().buyItem(order.totalPrice);
                order.acceptFinishOrder();
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
}