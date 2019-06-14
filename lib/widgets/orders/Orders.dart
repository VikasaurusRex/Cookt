import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'OrderList.dart';

class Orders extends StatelessWidget {

  final List<String> labels = ['Active', 'Past',];
  final List<Query> queries = [
    Firestore.instance.collection('orders').where('active', isEqualTo: true).where('customerID', isEqualTo: 'usercustomer'),
    Firestore.instance.collection('orders').where('active', isEqualTo: false).where('customerID', isEqualTo: 'usercustomer'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: labels.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0), // here the desired height
          child: AppBar(
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: TabBar(
              tabs: labels.map((label) => Tab(text: label)).toList(),
            ),
          ),
        ),
        body: TabBarView(
          children: queries.map((query)=>OrderList(query, labels[queries.indexOf(query)])).toList(),
        ),
      ),
    );
  }
}