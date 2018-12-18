import 'package:flutter/material.dart';

class AddFormPage extends StatefulWidget {
  @override
  _AddFormPageState createState() => _AddFormPageState();
}

class _AddFormPageState extends State<AddFormPage> {
  // One TextEditingController for each form input:
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // new page needs scaffolding!
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 32.0,
          ),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                onChanged: (text) => nameController.text = text,
                decoration: InputDecoration(
                  labelText: 'Name Here',
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.0),
              ),
              Builder(
                builder: (context) {
                  return RaisedButton(
                    onPressed: () => print("Pressed"),
                    color: Theme.of(context).cardColor,
                    child: Text('Create New Room'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}