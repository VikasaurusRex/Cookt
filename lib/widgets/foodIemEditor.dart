import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cookt/models/foodItem.dart';
import 'currentOrders.dart';

class FoodItemEditor extends StatefulWidget {
  @override
  _FoodItemEditorState createState() => _FoodItemEditorState();
}

class _FoodItemEditorState extends State<FoodItemEditor> {
  // One TextEditingController for each form input:

  bool newItem = true;
  FoodItem editableItem = FoodItem.newItem();
  List<File> images = List(6);

  TextEditingController pricePaidController = TextEditingController();
  TextEditingController priceReceivedController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    pricePaidController.text = editableItem.price.toStringAsFixed(2);
    priceReceivedController.text = (editableItem.price*(1-FoodItem.cooktPercent)).toStringAsFixed(2);
    // new page needs scaffolding!
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New"),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          iconSize: 40.0,
          onPressed: _showCurrentOrders,
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              foodName(),
              Padding(padding: EdgeInsets.all(4.0),),
              imagesScaffold(),
              Padding(padding: EdgeInsets.all(4.0),),
              description(),
              Padding(padding: EdgeInsets.all(4.0),),
              dineInAvailability(),
              Padding(padding: EdgeInsets.all(4.0),),
              categories(),
              Padding(padding: EdgeInsets.all(4.0),),
              price(),
              Padding(padding: EdgeInsets.all(20.0),),
              Container(
                height: 60.0,
                child: RaisedButton(
                  onPressed: createFoodItem,
                  color: Theme.of(context).cardColor,
                  child: Text(newItem?"Create Food Item":"Save Edits"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future _showCurrentOrders() async {
    // push a new route like you did in the last section
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return CurrentOrders();
        },
      ),
    );
  }

  Widget foodName(){
    return TextField(
      onSubmitted: (text){
        editableItem.name = text;
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: "Food Name",
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.name==''?Colors.red:Theme.of(context).hintColor),),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.name==''?Colors.red:Theme.of(context).hintColor),),
        labelStyle: TextStyle(color: editableItem.name==''?Colors.red:Theme.of(context).hintColor),
      ),
    );
  }

  Widget imagesScaffold(){
    double spacing = 2.0;
    return LayoutBuilder(builder: (content, constraints) {
      Size size = Size(constraints.maxWidth, constraints.maxWidth);
      return Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: size.width,
            maxHeight: size.height,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    _imageButton(0, flex: 2), // Largest Image
                    Padding(padding: EdgeInsets.all(spacing),),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _imageButton(1), // Top Right
                          Padding(padding: EdgeInsets.all(spacing),),
                          _imageButton(2), // Mid Right
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(spacing),),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    _imageButton(5), // Bottom Right
                    Padding(padding: EdgeInsets.all(spacing),),
                    _imageButton(4), // Mid Bottom
                    Padding(padding: EdgeInsets.all(spacing),),
                    _imageButton(3), // Left Bottom
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _imageButton(int index, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: images[index]!=null?FileImage(images[index]):NetworkImage('http://vikramhegde.org/transparent.png'),
            ),
          ),
          child: FlatButton(
            onPressed: getImage,
          ),
        ),
      )
    );
  }

  Future getImage({int index}) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if(editableItem.numImages < 6) {
        images[editableItem.numImages] = image;
        editableItem.numImages++;
      }
    });
  }

  Widget description() {
    return Builder(
      builder: (context){
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          onSubmitted: (text){
            editableItem.description = text;
            setState(() {});
          },
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: "Food Description",
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: editableItem.description==''?Colors.red:Theme.of(context).hintColor),),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: editableItem.description==''?Colors.red:Theme.of(context).hintColor),),
            labelStyle: TextStyle(color: editableItem.description==''?Colors.red:Theme.of(context).hintColor),
          ),

        );
      },
    );
  }

  Widget price(){
    return Container(
      height: 40.0,
      child: Builder(
        builder: (context){
          return Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: TextField(
                  controller: pricePaidController,
                  keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                  onSubmitted: (text) {
                    editableItem.price = isNum(text)?double.parse(text):0.0;
                    setState(() {});
                    priceReceivedController.text = isNum(text)?(double.parse(text)*(1-FoodItem.cooktPercent)).toStringAsFixed(2):'0.00';
                    return pricePaidController.text = isNum(text)?double.parse(text).toStringAsFixed(2):'0.00';
                  },
                  decoration: InputDecoration(
                      labelText: "Customer Pays (\$)",
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),),
                      labelStyle: TextStyle(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),
                  ),
                  style: TextStyle(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),
                ),
              ),
              Padding(padding: EdgeInsets.all(8.0),),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: priceReceivedController,
                  keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                  onSubmitted: (text) {
                    editableItem.price = isNum(text)? double.parse(text)*(1+FoodItem.cooktPercent):0.0;
                    setState(() {});
                    pricePaidController.text = isNum(text)?(double.parse(text)*(1+FoodItem.cooktPercent)).toStringAsFixed(2):'0.00';
                    return priceReceivedController.text = isNum(text)?double.parse(text).toStringAsFixed(2):'0.00';
                  },
                  decoration: InputDecoration(
                    labelText: "You Recieve (\$)",
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),),
                    labelStyle: TextStyle(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),
                  ),
                  style: TextStyle(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),
                ),
              )

            ],
          );
        },
      ),
    );
  }

  Widget dineInAvailability(){
    return Container(
      height: 40.0,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: Builder(
              builder:(context){
                return Text(
                  'Dine in Available',
                  style: Theme.of(context).textTheme.subhead,
                );
              },
            )

          ),
          Expanded(
            flex: 2,
            child: Switch.adaptive(
              value: editableItem.dineInAvailable,
              onChanged: (value) => setState(() => editableItem.dineInAvailable = value)
            ),
          ),
        ],
      ),
    );
  }

  Widget categories(){
    bool leftCol = false;
    List<Widget> left = [];
    List<Widget> right = [];

    for(String name in FoodItem.allCategories){
      Widget button = Container(
        height: 50.0,
        child: FlatButton(
          onPressed: (){
            if(editableItem.categories.contains(name)){
              editableItem.categories.remove(name);
            }else{
              editableItem.categories.add(name);
            }
            print(editableItem.categories);
            setState((){});
            setState((){});
          },
          splashColor: editableItem.categories.contains(name)?Theme.of(context).splashColor:Colors.greenAccent,
          child: Text(
            '$name',
            style: Theme.of(context).textTheme.subhead.apply(
              color: editableItem.categories.contains(name)?Colors.green:Theme.of(context).textTheme.subhead.color,
              fontWeightDelta: editableItem.categories.contains(name)?2:0,
            ),
          ),
        ),
      );
      if(leftCol){
        left.add(button);
      }else{
        right.add(button);
      }
      leftCol = !leftCol;
    }

    return Container(
      child: Row(
        children: <Widget>[
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: left,
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: right,
            ),
          ),
        ],
      ),
    );
  }

  bool isNum(String text){
    try{
      var value = double.parse(text);
    } on FormatException {
      return false;
    }
    return true;
  }

  void createFoodItem() async {
    // update/upload pictures
    // update/create fooditem

    if(editableItem.name == '' ||  editableItem.description == '' || editableItem.price < 0.01){
      print('Not Correct Values');
      _checkErrors();
      return;
    }

    if(newItem) {
      Future<DocumentReference> ref = editableItem.createListing();
      editableItem.reference = await ref;
    } else {
      editableItem.updateListingWithData(editableItem.reference);
    }

    int index = 0;
    for(File image in images){
      if(image != null){
        FirebaseStorage.instance.ref().child('images').child('${editableItem.reference.documentID}-$index').putFile(image);
        index++;
      }
    }
    print('Created');
  }

  Future<void> _checkErrors() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Incorrect Parameters'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Check above fields for omissions.'),
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