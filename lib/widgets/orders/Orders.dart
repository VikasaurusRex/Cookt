import 'package:flutter/material.dart';

class Orders extends StatelessWidget {

  final List<String> labels = ['Cart','Pending', 'Past Orders'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: labels.length,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: labels.map((label)=>Tab(text: label)).toList(),
          ),
        ),
        body: TabBarView(
          children: labels.map((label)=>Center( child: Text(label))).toList(),
        ),
      ),
    );
  }
}