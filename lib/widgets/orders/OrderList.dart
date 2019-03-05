import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/orders/Order.dart';
import 'package:cookt/widgets/orders/OrderTile.dart';

class OrderList extends StatefulWidget {
  final Query query;

  OrderList(this.query);

  @override
  State<StatefulWidget> createState() =>_OrderListState(query);
}

class _OrderListState extends State<OrderList> with AutomaticKeepAliveClientMixin<OrderList> {

  final Query query;
  List<Order> orders = List();

  _OrderListState(this.query){
    query.snapshots().forEach((querySnapshot){
      querySnapshot.documents.forEach((snapshot){
        print('  Found the snapshot ${snapshot.documentID}: ${snapshot.data}');
        if(!orders.contains(Order.fromSnapshot(snapshot))){
          setState(() {
            orders.add(Order.fromSnapshot(snapshot));
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Number of orders: ${orders.length}');
    return Container(
      child: ListView(
        children: orders.map((order) => OrderTile(order)).toList(),
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}