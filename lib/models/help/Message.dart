import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String message;
  final DateTime sentOn;
  final bool isFromSupport;

  DocumentReference reference;

  Message.fromMap(Map<String, dynamic> map, {@required this.reference}) :
        assert(map['message'] != null),
        assert(map['sentOn'] != null),
        assert(map['isFromSupport'] != null),
        this.message = map['message'],
        this.sentOn = map['sentOn'],
        this.isFromSupport = map['isFromSupport'];

  Message.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Message.from({@required this.message, this.isFromSupport = false})
  : this.sentOn = DateTime.now();

  @override
  String toString() => "$message $sentOn\n";

  Future<DocumentReference> create(DocumentReference ref) async {
    Map<String, dynamic> map = Map();
    map['message'] = message;
    map['sentOn'] = sentOn;
    map['isFromSupport'] = isFromSupport;

    ref.collection('messages').add(map).then((ref){
      this.reference = ref;
      return ref;
    });
  }

  bool operator ==(other) {
    return (other is Message && other.reference == reference);
  }
}