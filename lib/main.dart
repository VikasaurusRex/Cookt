import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stripe_payment/stripe_payment.dart';

import 'package:cookt/widgets/browse/Browse.dart';
import 'package:cookt/widgets/search/Search.dart';
import 'package:cookt/widgets/orders/Orders.dart';
import 'package:cookt/widgets/profile/Profile.dart';

import 'package:cookt/models/Services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "Cookt",
      home: Home(),
      theme: ThemeData(
//        primarySwatch:
//        MaterialColor(
//            0xff00ff00,
//          {
//            50: Color(0xffff0000),
//            100: Color(0xffff0000), // <-----
//            200: Color(0xff00ff00),
//            300: Color(0xff00ff00),
//            400: Color(0xff00ff00),
//            500: Color(0xff00ff00),
//            600: Color(0xff00ff00),
//            700: Color(0xff0000ff), // <-----
//            800: Color(0xff0000ff),
//            900: Color(0xff0000ff),
//          }
//        ),
        //accentColor: ,
        //cardColor: Colors.greenAccent,
        //disabledColor: ,
        fontFamily: 'OpenSans',
        buttonTheme: ButtonThemeData(
          padding: EdgeInsets.all(0),
          layoutBehavior: ButtonBarLayoutBehavior.constrained,
        ),
        hintColor: Theme.of(context).primaryColorDark,
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

  // TODO: Everything interactable made uppercase

  int _currentIndex = 0;

  List<Widget> _children;
  List<Widget> _appBars;

  Map<String, int> _specializedIndices = Map();

  @override
  Widget build(BuildContext context) {

    StripeSource.setPublishableKey("pk_test_tUqX0hO8KO1d3yf43EcqNwKh00glibgjaJ");
    _specializedIndices['CurrentSearch'] = 0;

    _appBars = [
      null, //Text('Home'),
      null,
      null,
      Text('Profile')
    ];

    _children = [
      Browse(),
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

  // TODO: Delete Function (Or Keep if expected Scripting in future)
  void scriptRunner(){
//    Container(
//      child: Center(
//        child: RaisedButton(
//          onPressed: scriptRunner,
//          child: Text('Run Script'),
//        ),
//      ),
//    ),

    Firestore.instance.collection('orders').getDocuments().then((orderQuery){
      orderQuery.documents.forEach((orderSnap){
        orderSnap.reference.collection('items').getDocuments().then((itemQuery){
          itemQuery.documents.forEach((itemSnap){
            itemSnap.reference.collection('selections').getDocuments().then((selectionQuery){
              selectionQuery.documents.forEach((selectionSnap){
                if(selectionSnap.data['title'] == 'Base'){
                  Map<String, dynamic> map = Map();
                  map['prices'] = [0];
                  selectionSnap.reference.updateData(map);
                }else{
                  Map<String, dynamic> map = Map();
                  map['prices'] = [0.5, 0.35];
                  selectionSnap.reference.updateData(map);
                }
              });
            });
          });
        });
      });
    });
    print('hello wrld');
  }
}




// MARK: Placeholders for Development of Specialized Widgets
// TODO: Delete the class

class PlaceholderWidget extends StatefulWidget {
  final Color color;

  PlaceholderWidget(this.color);

  @override
  State<StatefulWidget> createState() =>_PlaceholderWidgetState();
}

class _PlaceholderWidgetState extends State<PlaceholderWidget> {
  String _name = "";

  void loadData() {
    Services.foodName("1yzdDBacqdeRxewvuczy").then((val) => setState(() {
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