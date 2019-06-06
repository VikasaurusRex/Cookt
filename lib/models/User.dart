import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String firstname;
  String lastname;
  String kitchenname;
  bool dineInAvailable;
  final bool verified;
  GeoPoint loc;

  DocumentReference reference;

  User.fromMap(Map<String, dynamic> map, {@required this.reference})
      :
        assert(map['firstname'] != null),
        assert(map['lastname'] != null),
        this.firstname = map['firstname'],
        this.lastname = map['lastname'],
        this.kitchenname = map['kitchenname'],
        this.verified = map['verified'],
        this.loc = map['loc'];

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  User.newUser(String firstname, String lastname)
      :
        this.firstname = firstname,
        this.lastname = lastname,
        this.kitchenname = null,
        this.dineInAvailable = null,
        this.verified = null,
        this.loc = null,
        this.reference = null;

  @override
  String toString() => "${reference.documentID} $firstname $lastname";

  void create(String uid) {
    Map<String, dynamic> map = Map();
    map['firstname'] = firstname;
    map['lastname'] = lastname;
    map['kitchenname'] = kitchenname;
    map['dineInAvailable'] = dineInAvailable;
    map['verified'] = verified;
    map['loc'] = loc;

    Firestore.instance.collection('users').document(uid).updateData(map);
    this.reference = Firestore.instance.collection('users').document(uid);
  }

  bool operator ==(other) {
    return (other is User && other.reference == reference);
  }
}
