import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/services/Services.dart';
import 'package:cookt/models/help/Conversation.dart';

import 'package:cookt/widgets/settings/HelpNewIssue.dart';
import 'package:cookt/widgets/settings/HelpChat.dart';

class Help extends StatefulWidget {

  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  List<Conversation> conversations = [];

  _HelpState(){
    Firestore.instance
        .collection("help")
        .where("uid", isEqualTo: "usercustomer")
        .getDocuments().then((onValue) {
      setState(() {
        conversations = onValue.documents.map((snapshot) =>
            Conversation.fromSnapshot(snapshot)).toList();
        conversations.forEach((convo) => convo.getMessages());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: conversations.length > 0?AppBar(
          title: Text('Help Console'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              iconSize: 40.0,
              onPressed: _showNewIssue,
            ),
          ]
      ):null,
      body: conversations.length > 0? ListView(
        padding: const EdgeInsets.only(top: 16.0),
        children: conversations.map((conversation) => _conversationCell(conversation)).toList(),
      ):HelpNewIssue(),
    );
  }

  // TODO: On new ticket, add the conversation to the list of conversations here.
  Future _showNewIssue() async {
    // push a new route like you did in the last section
    // TODO: Uncomment and Add a conversation view.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return HelpNewIssue();
        },
      ),
    );
  }

  Widget _conversationCell(Conversation conversation) {
    return FlatButton(
      //color: Colors.red,
      padding: EdgeInsets.all(0),
      onPressed: () {
        // TODO: Uncomment and Add a conversation view.
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return HelpChat(conversation);
                },
              ),
            );
      },
      child:Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(conversation.title, style: Theme.of(context).textTheme.subtitle.apply(fontSizeFactor: 1.2,), textAlign: TextAlign.left,),
              )
            ],
          ),
        )
      ),
    );
  }
}
