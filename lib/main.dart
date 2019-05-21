import 'package:flutter/material.dart';

import 'package:cookt/widgets/browse/Browse.dart';
import 'package:cookt/widgets/search/Search.dart';
import 'package:cookt/widgets/orders/Orders.dart';
import 'package:cookt/widgets/profile/Profile.dart';

import 'package:cookt/widgets/sell/SaleHome.dart';

import 'package:cookt/models/DatabaseIntegrator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: "Cookt",
      home: Home(),
      theme: ThemeData(
        //primarySwatch: Colors.red,
        buttonTheme: ButtonThemeData(
          padding: EdgeInsets.all(0),
          layoutBehavior: ButtonBarLayoutBehavior.constrained,
        ),
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

  List<Widget> _children;
  List<Widget> _appBars;

  Map<String, int> _specializedIndices = Map();

  @override
  Widget build(BuildContext context) {

    _specializedIndices['CurrentSearch'] = 0;

    _appBars = [
      Text('Home'),
      null,
      null,
      Text('Profile')
    ];

    _children = [
      PlaceholderWidget(Colors.red),
      Search(),
      Orders(),
      Profile()
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
    );
  }

  // MARK: Main Controller Methods

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // MARK: Home Controller Methods

  // MARK: Search Controller Methods

  // MARK: Order Controller Methods

  // MARK: Profile Controller Methods
}




// MARK: Placeholders for Development of Specialized Widgets

class PlaceholderWidget extends StatefulWidget {
  final Color color;

  PlaceholderWidget(this.color);

  @override
  State<StatefulWidget> createState() =>_PlaceholderWidgetState();
}

class _PlaceholderWidgetState extends State<PlaceholderWidget> {
  String _name = "";

  void loadData() {
    DatabaseIntegrator.foodName("1yzdDBacqdeRxewvuczy").then((val) => setState(() {
      _name = val;
    }));
  }

  _PlaceholderWidgetState(){
    loadData();
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