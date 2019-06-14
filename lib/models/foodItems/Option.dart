import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Option {
  int maxSelection;
  List<String> options;
  List<double> price;
  String title;

  DocumentReference reference;

  Option.fromMap(Map<String, dynamic> map, {@required this.reference}) :
        assert(map['maxSelection'] != null),
        assert(map['options'] != null),
        assert(map['price'] != null),
        assert(map['title'] != null),
        this.maxSelection = map['maxSelection'],
        this.options = List<String>.from(map['options']),
        this.price = List<double>.from(List<dynamic>.from(map['price']).map((dbl) => dbl.toDouble()).toList()),
        this.title = map['title'];

  Option.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Option.newOption() :
    this.maxSelection = 2,
    this.options = ['Option 1', 'Option 2'],
    this.price = [0.0, 0.0],
    this.title = 'Option Title',
    this.reference = null;

  @override
  String toString() => "$title : $options";

  Future<DocumentReference> create(DocumentReference reference) async {
    Map<String, dynamic> map = Map();
    map['maxSelection'] = maxSelection;
    map['options'] = options;
    map['price'] = price;
    map['title'] = title;

    reference.collection('options').add(map).then((ref){
      this.reference = ref;
      return ref;
    });
  }

  void updateOption() {
    Map<String, dynamic> map = Map();
    map['maxSelection'] = maxSelection;
    map['options'] = options;
    map['price'] = price;
    map['title'] = title;

    reference.updateData(map);
  }

  void deleteOption(){
    if(reference == null)
      return;
    reference.delete();
  }

  bool operator ==(other) {
    return (other is Option && other.reference == reference);
  }
}