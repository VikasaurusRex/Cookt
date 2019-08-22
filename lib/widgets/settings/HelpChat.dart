import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/services/Services.dart';
import 'package:cookt/models/help/Conversation.dart';
import 'package:cookt/models/help/Message.dart';

import 'package:cookt/widgets/settings/HelpNewIssue.dart';

class HelpChat extends StatefulWidget {

  Conversation convo;

  HelpChat(this.convo);

  @override
  _HelpChatState createState() => _HelpChatState(this.convo);
}

class _HelpChatState extends State<HelpChat> {
  Conversation convo;
  TextEditingController chatController = TextEditingController();

  _HelpChatState(this.convo){
    this.convo.getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Help Console'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ListView(
                padding: const EdgeInsets.only(top: 16.0),
                children: convo.messages.map((message) => _messageCell(message)).toList(),
              ),
            ),
          ),
          TextField(
            controller: chatController,
            onSubmitted: (text){
              setState(() {
                convo.addMessage(message: text, isFromSupport: false);
              });
              chatController.text = '';
            },
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
              labelStyle: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCell(Message message) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Text(message.message, style: Theme.of(context).textTheme.subtitle.apply(fontSizeFactor: 1.2,), textAlign: message.isFromSupport? TextAlign.left:TextAlign.right,),
      ),
    );
  }
}
