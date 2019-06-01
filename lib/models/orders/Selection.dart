import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

//TODO: Change the database to include these price values (PLS WRITE SCRPIT LMAO)
class Selection {
  final String title;
  final List<String> selections;
  final List<double> prices;

  DocumentReference reference;

  Selection.fromMap(Map<String, dynamic> map, {@required this.reference}) :
        assert(map['title'] != null),
        assert(map['selections'] != null),
        assert(map['prices'] != null),
        this.title = map['title'],
        this.selections = List<String>.from(map['selections']),
        this.prices = List<double>.from(map['prices']);

  Selection.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Selection.from(this.title) :
        this.reference = null,
        this.selections = [],
        this.prices = [];

  @override
  String toString() => "$title $selections $prices\n";

  void createSelection() {
    Map<String, dynamic> map = Map();
    map['title'] = title;
    map['selections'] = selections;
    map['prices'] = prices;

    reference.updateData(map);
  }

  void reorder(DocumentReference ref) async {
    Map<String, dynamic> map = Map();
    map['title'] = title;
    map['selections'] = selections;
    map['prices'] = prices;

    ref.collection('selections').add(map);
  }

  bool operator ==(other) {
    return (other is Selection && other.reference == reference);
  }
}