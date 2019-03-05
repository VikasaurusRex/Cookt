import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/orders/Order.dart';
import 'package:cookt/models/orders/Item.dart';
import 'package:cookt/widgets/orders/SelectionList.dart';

class OrderTile extends StatefulWidget {
  final Order order;

  OrderTile(this.order);

  @override
  State<StatefulWidget> createState() =>_OrderTileState(order);
}

class _OrderTileState extends State<OrderTile> {
  final Order order;
  List<Item> items = List();

  _OrderTileState(this.order){
    print('  Searching for Items');
    order.reference.collection('items').snapshots().forEach((querySnapshot){
      querySnapshot.documents.forEach((snapshot){
        print('  Found the item ${snapshot.documentID}: ${snapshot.data}');
        if(!items.contains(Item.fromSnapshot(snapshot))){
          setState(() {
            items.add(Item.fromSnapshot(snapshot));
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('  Number of items in order: ${items.length}');
    return Container(
      color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => SelectionList(item)).toList(),
      ),
    );
  }
}