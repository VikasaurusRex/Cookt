import 'package:flutter/material.dart';

class Address extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>_AddressState();
}

class _AddressState extends State<Address> {

  // TODO: Conversation object with details and list of Message
  // TODO: Message object with support agent etc.

  TextEditingController issueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Text('Help'),),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Change Address', style: Theme.of(context).textTheme.title.apply(fontWeightDelta: 1),),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: _address(),
            ),
            RaisedButton(
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text('Change Address'),
              ),
              onPressed: changeAddress,
            )
          ],
        ),
      ),
    );
  }

  void changeAddress() async {

    // TODO: Actually change address
    Navigator.of(context).pop();
    _confirmAddressChange();
  }

  Widget _address(){
    return TextField(
      keyboardType: TextInputType.multiline,
      maxLines: 2,
      controller: issueController,
      onSubmitted: (text){
        issueController.text = text;
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: "New Address",
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
        labelStyle: TextStyle(color: Theme.of(context).hintColor),
      ),
    );
  }

  Future<void> _confirmAddressChange() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Address Changed.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your address has been updated!'),
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