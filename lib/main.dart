import 'package:flutter/material.dart';


import 'package:cookt/widgets/browse/Browse.dart';
import 'package:cookt/widgets/search/Search.dart';
import 'package:cookt/widgets/orders/Orders.dart';
import 'package:cookt/widgets/profile/Profile.dart';

import 'package:cookt/widgets/browse/BrowseBar.dart';
import 'package:cookt/widgets/search/SearchBar.dart';
import 'package:cookt/widgets/orders/OrdersBar.dart';
import 'package:cookt/widgets/profile/ProfileBar.dart';

import 'package:cookt/models/DataFetcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cookt",
      home: Home(),
      theme: ThemeData(
//        primaryColor: Colors.white,
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {

  int _currentIndex = 0;

  final List<Widget> _children = [
    PlaceholderWidget(Colors.white),
    PlaceholderWidget(Colors.grey),
    PlaceholderWidget(Colors.black54),
    PlaceholderWidget(Colors.black)
  ];

  final List<Widget> _appBars = [

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,//_appBars[_currentIndex],
      body: _children[_currentIndex], // new
      bottomNavigationBar: new Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Theme.of(context).primaryColorDark
        ), // sets the inactive color of the `BottomNavigationBar`
        child: BottomNavigationBar(
          onTap: onTabTapped, // new
          currentIndex: _currentIndex, // new
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text('Search'),
            ),
            new BottomNavigationBarItem(
                icon: Icon(Icons.receipt),
                title: Text('Orders')
            ),
            new BottomNavigationBarItem(
                icon: Icon(Icons.person),
                title: Text('Profile')
            ),
          ],
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class PlaceholderWidget extends StatefulWidget {
  final Color color;

  PlaceholderWidget(this.color);

  @override
  State<StatefulWidget> createState() =>_PlaceholderWidgetState();
}

class _PlaceholderWidgetState extends State<PlaceholderWidget> {
  String _name = "";

  _getName() {
    DataFetcher.nameAbbreviated("usercook").then((val) => setState(() {
      _name = val;
    }));
  }

  _PlaceholderWidgetState(){
    _getName();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      child: Center(
        child: Text(_name),
      ),
    );
  }
}