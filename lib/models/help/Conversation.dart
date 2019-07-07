import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'Message.dart';

class Conversation {
  final String title;
  final DateTime createdOn;
  final String uid;

  List<Message> messages = [];

  DocumentReference reference;

  Conversation.fromMap(Map<String, dynamic> map, {@required this.reference}) :
        assert(map['title'] != null),
        assert(map['createdOn'] != null),
        assert(map['uid'] != null),
        this.title = map['title'],
        this.createdOn = map['createdOn'],
        this.uid = map['uid'];

  Conversation.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Conversation.from(this.title, String message) :
        this.reference = null,
        this.createdOn = DateTime.now(),
        this.uid = 'usercustomer',
        this.messages = [Message.from(message: message)];

  @override
  String toString() => "$title $createdOn $reference\n";

  List<Message> getMessages(){
    reference.collection('messages').orderBy('sentOn', descending: false).getDocuments().then((query){
      messages = query.documents.map((message) => Message.fromSnapshot(message)).toList();
    });
  }

  void addMessage({@required message, @required isFromSupport}){
    Message messageModel = Message.from(message: message, isFromSupport: isFromSupport);
    messages.add(messageModel);
    messageModel.create(reference);
  }

  Future<DocumentReference> create() async {
    Map<String, dynamic> map = Map();
    map['title'] = title;
    map['createdOn'] = createdOn;
    map['uid'] = uid;

    Firestore.instance.collection('help').add(map).then((ref){
      this.reference = ref;
      messages.forEach((message){
        if(message.reference == null)
          message.create(reference);
      });
      return ref;
    });
  }

  bool operator ==(other) {
    return (other is Conversation && other.reference == reference);
  }
}