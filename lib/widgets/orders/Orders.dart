import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'OrderList.dart';

class Orders extends StatelessWidget {

  final List<String> labels = ['Current Orders', 'Past Orders'];
  final List<Query> queries = [
    Firestore.instance.collection('orders').where('status', isEqualTo: 'PENDING').where('customerID', isEqualTo: 'usercustomer'),
    Firestore.instance.collection('orders').where('status', isEqualTo: 'COMPLETED').where('customerID', isEqualTo: 'usercustomer'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: labels.length,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: TabBar(
            tabs: labels.map((label)=>Tab(text: label)).toList(),
          ),
        ),
        body: TabBarView(
          children: queries.map((query)=>OrderList(query)).toList(),
        ),
      ),
    );
  }
}