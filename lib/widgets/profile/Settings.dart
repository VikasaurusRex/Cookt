import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>_SettingsState();
}

class _SettingsState extends State<Settings> {

  // TODO: allow for changes to name, store name and dineInAvailable

  _SettingsState(){

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings'),),
      body: Container(),
    );
  }
}