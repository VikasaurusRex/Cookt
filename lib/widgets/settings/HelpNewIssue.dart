import 'package:flutter/material.dart';

import 'package:cookt/models/help/Conversation.dart';

class HelpNewIssue extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>_HelpNewIssueState();
}

class _HelpNewIssueState extends State<HelpNewIssue> {

  // TODO: Conversation object with details and list of Message
  // TODO: Message object with support agent etc.

  TextEditingController issueController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Issue'),),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Get Help', style: Theme.of(context).textTheme.title.apply(fontWeightDelta: 1),),
            ),
            Padding(

              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: _foodName(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: _description(),
            ),
            RaisedButton(
              child: Text('New Issue'),
              onPressed: createTicket,
            )
          ],
        ),
      ),
    );
  }

  void createTicket() async {
    if(issueController.text == null || issueController.text == '')
      return;

    Conversation newSupport = Conversation.from(issueController.text, detailsController.text);
    newSupport.create();

    Navigator.of(context).pop(); // TODO: Push to conversation screen
    _confirmSend();
  }

  Widget _foodName(){
    return TextField(
      controller: issueController,
      onSubmitted: (text){
        issueController.text = text;
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: "Issue",
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
        labelStyle: TextStyle(color: Theme.of(context).hintColor),
      ),
    );
  }

  Widget _description() {
    return TextField(
      keyboardType: TextInputType.multiline,
      maxLines: 5,
      controller: detailsController,
      onSubmitted: (text){
        detailsController.text = text;
        setState(() {});
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: "Details",
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
        labelStyle: TextStyle(color: Theme.of(context).hintColor),
      ),
    );
  }

  Future<void> _confirmSend() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Ticket Created.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You will be assisted with your problem soon!'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}