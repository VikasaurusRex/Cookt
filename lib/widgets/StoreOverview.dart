import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:io';


import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/user/User.dart';
import 'package:cookt/services/Services.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/widgets/search/FoodItemTile.dart';

class StoreOverview extends StatefulWidget {

  User cook;

  StoreOverview(this.cook);

  @override
  _StoreOverviewState createState() => _StoreOverviewState();
}

class _StoreOverviewState extends State<StoreOverview> {

  List<FoodItem> myFoodItems = [];
  Map<String, File> foodImaged = Map();

  ScrollController scroller = ScrollController();
  GoogleMapController mapController;
  LatLng myCoords = null;
  LatLng cookCoords = null;

  _StoreOverviewState(){
    loadLocation();

    scroller = ScrollController();
    scroller.addListener(updateMap);

    Firestore.instance
        .collection("fooddata")
        .where("uid", isEqualTo: "usercook")
        .orderBy('isHosting', descending: true)
        .getDocuments().then((onValue) {
      setState(() {
        myFoodItems = onValue.documents.map((snapshot) => FoodItem.fromSnapshot(snapshot)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    updateMap();
    return Scaffold(
      //backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(title: Text('${widget.cook.kitchenname}'),),
      body: ListView(
        controller: scroller,
        children: <Widget>[
          _userImage(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4.0),
            child: Text(
              'From ${widget.cook.hometown}',
              style: Theme.of(context).textTheme.headline.apply(
                  fontSizeFactor: 0.8,
                  color: Colors.black26
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0.0),
            child: Text(
              '${widget.cook.kitchenname}',
              style: Theme.of(context).textTheme.headline.apply(
                  fontSizeFactor: 1.4,
                  fontWeightDelta: 2,
                  color: Theme.of(context).primaryColorDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
            child: Text(
              'Chef ${widget.cook.firstname} ${widget.cook.lastname}',
              style: Theme.of(context).textTheme.headline.apply(
                  fontSizeFactor: 0.8,
                  color: Theme.of(context).primaryColor
              ),
              textAlign: TextAlign.center,
            ),
          ),
          widget.cook.about != null? Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Text(
              widget.cook.about,
              style: Theme.of(context).textTheme.title.apply(
                  fontSizeFactor: 1,
                  color: Theme.of(context).primaryColorDark,
              ),
              textAlign: TextAlign.center,
            ),
          ): Container(),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: Container(
              height: 1,
              color: Colors.black12,
            ),
          ),
          _map(),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Container(
              height: 1,
              color: Colors.black12,
            ),
          ),
          widget.cook.because != null? _sectionTitle('I cook because...'): Container(),
          widget.cook.because != null? _textBox(widget.cook.because): Container(),
          widget.cook.favFood != null? _sectionTitle('My favorite food is...'): Container(),
          widget.cook.favFood != null? _textBox(widget.cook.favFood): Container(),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 40, 10, 10),
            child: Container(
              height: 1,
              color: Colors.black12,
            ),
          ),
          _title('My Selection'),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: myFoodItems.map((foodItem) => FoodItemTile(foodItem, widget.cook, false, key: Key(foodItem.toString()))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _title(String text){
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 10, 0, 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.subhead.apply(
          fontWeightDelta: 2,
          fontSizeFactor: 2,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text){
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 20, 0, 0),
      child: Text(
          text,
          style: Theme.of(context).textTheme.subhead.apply(
            color: Colors.black54
          )
      ),// textAlign: TextAlign.center,),
    );
  }

  Widget _textBox(String text){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.subhead.apply(
          fontSizeFactor: 1.5,
          color: Theme.of(context).primaryColorDark
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _userImage(){
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Column(
            children: <Widget>[
              InkWell(
                onTap:  widget.cook == null? null:(){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return StoreOverview(widget.cook);
                      },
                    ),
                  );
                },
                child: AspectRatio(
                  aspectRatio: 2,
                  child: Services.storefrontImage(widget.cook.reference.documentID),
                ),
              ),
              AspectRatio(
                aspectRatio: 2,
                child: Container(),//color: Colors.red,),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10000),
                  border: Border.all(width: 10, color: Theme.of(context).primaryColor,),
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10.0,
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10000),
                  child: Services.userImage(widget.cook.reference.documentID),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _map(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: AspectRatio(
        aspectRatio: 1,
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          // TODO: Change these map options
          options: GoogleMapOptions(
            mapType: MapType.hybrid,
            myLocationEnabled: true,
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: true,
            compassEnabled: true,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: true,
          ),
        ),
      ),
    );
  }

  void loadLocation() async{
    var location = new Location();
    try {
      Map<String, double> currentLocation = await location.getLocation();
      if(myCoords==null || (myCoords.latitude-currentLocation["latitude"]).abs()>=0.0001 || (myCoords.longitude-currentLocation["longitude"]).abs()>=0.0001)
        setState(() {
          myCoords = LatLng(currentLocation["latitude"], currentLocation["longitude"]);
        });
      updateMap();
    } on Exception {}

    Services.loc(widget.cook.reference.documentID).then((val) => setState(() {
      cookCoords = LatLng(val.latitude, val.longitude);
      updateMap();
    }));
  }

  void updateMap(){
    if(mapController == null || cookCoords == null) {
      return;
    }

    mapController.addMarker(
      MarkerOptions(
        position: cookCoords,
      ),
    );
    if(myCoords == null) {
      mapController.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(target: cookCoords, zoom: 15)
          )
      );
      return;
    }
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(myCoords.latitude<cookCoords.latitude?myCoords.latitude:cookCoords.latitude,
              myCoords.longitude<cookCoords.longitude?myCoords.longitude:cookCoords.longitude),
          northeast: LatLng(myCoords.latitude>cookCoords.latitude?myCoords.latitude:cookCoords.latitude,
              myCoords.longitude>cookCoords.longitude?myCoords.longitude:cookCoords.longitude),
        ),
        80.0,
      ),
    );
  }
}
