import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookt/models/orders/Order.dart';
import 'package:cookt/widgets/orders/OrderList.dart';

import 'IncomingOrderList.dart';

class SaleConsole extends StatelessWidget {

  final List<String> labels = ['Incoming', 'Previous',];
  final List<List<Query>> queries = [[
    Firestore.instance.collection('orders').where('status', isEqualTo: 'REQUESTED').where('active', isEqualTo: true).where('cookID', isEqualTo: 'usercook'),
    Firestore.instance.collection('orders').where('status', isEqualTo: 'ACCEPTED').where('active', isEqualTo: true).where('cookID', isEqualTo: 'usercook'),
  ],
  [
    Firestore.instance.collection('orders').where('active', isEqualTo: false).where('cookID', isEqualTo: 'usercook'),
  ]];

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
          children: queries.map((query)=>IncomingOrderList(query)).toList(),
        ),
      ),
    );
  }
}