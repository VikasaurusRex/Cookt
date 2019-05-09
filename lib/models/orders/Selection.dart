import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Selection {
  final String title;
  final List<dynamic> selections;

  DocumentReference reference;

  Selection.fromMap(Map<String, dynamic> map, {@required this.reference}) :
        assert(map['title'] != null),
        assert(map['selections'] != null),
        this.title = map['title'],
        this.selections = List<String>.from(map['selections']);

  Selection.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "$title $selections";

  void createSelection() {
    Map<String, dynamic> map = Map();
    map['title'] = title;
    map['selections'] = selections;

    reference.updateData(map);
  }

  void reorder(DocumentReference ref) async {
    Map<String, dynamic> map = Map();
    map['title'] = title;
    map['selections'] = selections;

    ref.collection('selections').add(map);
  }

  bool operator ==(other) {
    return (other is Selection && other.reference == reference);
  }
}