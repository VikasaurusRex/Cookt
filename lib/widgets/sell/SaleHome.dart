import 'package:flutter/material.dart';

import 'SaleConsole.dart';
import 'MyFoodItems.dart';

import 'EditFoodItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaleHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SaleHomeState();
  }
}

class _SaleHomeState extends State<SaleHome> {

  int _currentIndex = 0;

  List<Widget> _children;
  List<Widget> _appBars;

  @override
  Widget build(BuildContext context) {

    _appBars = [
      null,
      Text('My Food Items'),
    ];

    _children = [
      SaleConsole(),
      MyFoodItems(Colors.white),
    ];

    return Scaffold(
      appBar: _appBars[_currentIndex]==null?null:AppBar(title: _appBars[_currentIndex]),//_appBars[_currentIndex],
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.store),
            title: Text('Incoming Orders'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.local_pizza),
            title: Text('My Food Items'),
          ),
        ],
      ),
    );
  }

  // MARK: Main Controller Methods

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}