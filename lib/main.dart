import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import 'newFormPractice.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cookt',
      home: MyHomePage(),
      theme: ThemeData(
        primaryColor: Colors.black
      ),
    );
  }
}

//------------------------------------------------------------------------------

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cookt"),
        actions: [
//          IconButton(
//            icon: Icon(Icons.add),
//            onPressed: _showNewForm,
//          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: null,
        ),
      ),
      body: _buildBody(context),
    );
  }

//  Future _showNewForm() async {
//    // push a new route like you did in the last section
//    Navigator.of(context).push(
//      MaterialPageRoute(
//        builder: (BuildContext context) {
//          return AddFormPage();
//        },
//      ),
//    );
//  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Expanded(child: Center(child: LinearProgressIndicator()));
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final order = Order.fromSnapshot(data);
    return Padding(
      key: ValueKey(order.orderTime),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              order.cookName(),
              order.foodName(),
            ],
          )
        )
      ),
    );
  }
}

//------------------------------------------------------------------------------

class Order {
  final bool accepted;
  final String cookID;
  final String customerID;
  final bool dineIn;
  final String foodId;
  final String lastTouchedID;
  final DateTime lastTouchedTime;
  final DateTime orderTime;
  final DateTime pickupTime;
  final bool postmatesOrder;
  final int quantity;
  final String status;

  final DocumentReference reference;

  Order.fromMap(Map<String, dynamic> map, {this.reference}) :
        assert(map['accepted'] != null),
        assert(map['cookID'] != null),
        assert(map['customerID'] != null),
        assert(map['dineIn'] != null),
        assert(map['foodId'] != null),
        assert(map['lastTouchedID'] != null),
        assert(map['lastTouchedTime'] != null),
        assert(map['orderTime'] != null),
        assert(map['pickupTime'] != null),
        assert(map['postmatesOrder'] != null),
        assert(map['quantity'] != null),
        assert(map['status'] != null),
        this.accepted = map['accepted'],
        this.cookID = map['cookID'],
        this.customerID = map['customerID'],
        this.dineIn = map['dineIn'],
        this.foodId = map['foodId'],
        this.lastTouchedID = map['lastTouchedID'],
        this.lastTouchedTime = map['lastTouchedTime'],
        this.orderTime = map['orderTime'],
        this.pickupTime = map['pickupTime'],
        this.postmatesOrder = map['postmatesOrder'],
        this.quantity = map['quantity'],
        this.status = map['status'];

  Order.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "The food is $foodId at $pickupTime";

  Widget customerName(){
    return StreamBuilder<Event>(
      stream: FirebaseDatabase.instance.reference().child(customerID).child("userinfo").onValue,
      builder: (context, event) {
        if (!event.hasData) return Expanded(child: Center(child: LinearProgressIndicator()));
        return Text('${event.data.snapshot.value["firstname"]} ${event.data.snapshot.value["lastname"].toString().substring(0,1)}.');
      },
    );
  }

  Widget cookName(){
    return StreamBuilder<Event>(
      stream: FirebaseDatabase.instance.reference().child(cookID).child("userinfo").onValue,
      builder: (context, event) {
        if (!event.hasData) return Expanded(child: Center(child: LinearProgressIndicator()));
        return Text('${event.data.snapshot.value["firstname"]} ${event.data.snapshot.value["lastname"].toString().substring(0,1)}.');
      },
    );
  }

  Widget foodName(){
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection("fooddata").document(foodId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Expanded(child: Center(child: LinearProgressIndicator()));
        return Text('${snapshot.data["name"]}');
      },
    );
  }

}

//------------------------------------------------------------------------------

class FoodItem {
  final List<String> categories;
  final String description;
  final bool dineInAvailable;
  final bool isHosting;
  final List<String> likedBy;
  final String name;
  final int numImages;
  final int price;
  final DateTime timeCreated;
  final DateTime timeUpdated;
  final String uid;
  final List<Review> reviews = []; // must be done later

  final DocumentReference reference;

  FoodItem.fromMap(Map<String, dynamic> map, {this.reference}) :
        assert(map['categories'] != null),
        assert(map['description'] != null),
        assert(map['dineInAvailable'] != null),
        assert(map['isHosting'] != null),
        assert(map['likedBy'] != null),
        assert(map['name'] != null),
        assert(map['numImages'] != null),
        assert(map['price'] != null),
        assert(map['timeCreated'] != null),
        assert(map['timeUpdated'] != null),
        assert(map['uid'] != null),
        this.categories = map['categories'],
        this.description = map['description'],
        this.dineInAvailable = map['dineInAvailable'],
        this.isHosting = map['isHosting'],
        this.likedBy = map['likedBy'],
        this.name = map['name'],
        this.numImages = map['numImages'],
        this.price = map['price'],
        this.timeCreated = map['timeCreated'],
        this.timeUpdated = map['timeUpdated'],
        this.uid = map['uid'];

  FoodItem.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "The food is $name, $description";
}

class Review {
  final int rating;
  final String review;
  final String userid;
  final DateTime time;

  final DocumentReference reference;

  Review.fromMap(Map<String, dynamic> map, {this.reference}) :
        assert(map['rating'] != null),
        assert(map['review'] != null),
        assert(map['userid'] != null),
        assert(map['time'] != null),
        this.rating = map['rating'],
        this.review = map['review'],
        this.userid = map['userid'],
        this.time = map['time'];

  Review.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "$userid : $rating";
}

