import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String firstname;
  String lastname;
  String kitchenname;
  String about;
  String because;
  String favFood;
  String hometown;
  String email;
  bool dineInAvailable;
  final bool verified;
  GeoPoint loc;
  String custId;

  DocumentReference reference;



  User.fromMap(Map<String, dynamic> map, {@required this.reference})
      :
        assert(map['firstname'] != null),
        assert(map['lastname'] != null),
        assert(map['email'] != null),
        this.firstname = map['firstname'],
        this.lastname = map['lastname'],
        this.email = map['email'],
        this.kitchenname = map['kitchenname'],
        this.about = map['about'],
        this.because = map['because'],
        this.favFood = map['favFood'],
        this.hometown = map['hometown'],
        this.verified = map['verified'],
        this.loc = map['loc'],
        this.custId = map['custId'];

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  User.newUser(String firstname, String lastname, String email)
      :
        this.firstname = firstname,
        this.lastname = lastname,
        this.email = email,
        this.kitchenname = null,
        this.about = null,
        this.because = null,
        this.favFood = null,
        this.hometown = null,
        this.dineInAvailable = null,
        this.verified = null,
        this.loc = null,
        this.reference = null,
        this.custId = null;

  @override
  String toString() => "${reference.documentID} $firstname $lastname";

  void create(String uid) {
    Map<String, dynamic> map = Map();
    map['firstname'] = firstname;
    map['lastname'] = lastname;
    map['email'] = email;
    map['kitchenname'] = kitchenname;
    map['about'] = kitchenname;
    map['because'] = kitchenname;
    map['favFood'] = kitchenname;
    map['hometown'] = hometown;
    map['dineInAvailable'] = dineInAvailable;
    map['verified'] = verified;
    map['loc'] = loc;
    map['custId'] = custId;

    Firestore.instance.collection('users').document(uid).updateData(map);
    this.reference = Firestore.instance.collection('users').document(uid);
  }

  void updateLocation(double lat, double long) {
    Map<String, dynamic> map = Map();
    map['loc'] = GeoPoint(lat, long);

    reference.updateData(map);
  }

  bool operator ==(other) {
    return (other is User && other.reference == reference);
  }

  static Future<Map<String, User>> usersWithin({double distance = 5, GeoPoint location}) async{
    // ~1 mile of lat and lon in degrees
    double lat = 0.0144927536231884;
    double lon = 0.0181818181818182;

    if(location==null){
      Location loc = new Location();
      try {
        Map<String, double> currentLocation = await loc.getLocation();
        location = GeoPoint(currentLocation["latitude"], currentLocation["longitude"]);
      } on Exception {}
    }

    double lowerLat = location.latitude - (lat * distance);
    double lowerLon = location.longitude - (lon * distance);

    double greaterLat = location.latitude + (lat * distance);
    double greaterLon = location.longitude + (lon * distance);

    GeoPoint lesserGeopoint = GeoPoint(lowerLat, lowerLon);
    GeoPoint greaterGeopoint = GeoPoint(greaterLat, greaterLon);

    QuerySnapshot querySnap = await Firestore.instance.collection("users")
        .where("loc", isGreaterThan: lesserGeopoint)
        .where("loc", isLessThan: greaterGeopoint).getDocuments();
    Map<String, User> users = Map();
    querySnap.documents.forEach((doc){
      User user = User.fromSnapshot(doc);
      users[user.reference.documentID] = user;
    });
    return users;
  }

  static void updateAddress(GeoPoint loc, {String uid}){
    Firestore.instance.collection('users').document(uid).updateData({'loc': loc});
  }
}
