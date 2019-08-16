import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

import 'package:cookt/services/Services.dart';
import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/models/foodItems/Option.dart';


class EditFoodItem extends StatefulWidget {
  final DocumentReference reference;

  EditFoodItem({@required this.reference});

  @override
  _EditFoodItemState createState() => _EditFoodItemState(this.reference);
}

class _EditFoodItemState extends State<EditFoodItem> {

  //TODO: make categories different, more scrollier than bubblier

  // One TextEditingController for each form input:
  FoodItem editableItem = FoodItem.newItem();
  File addedImage;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  List<Option> orderOptions = List();
  List<DocumentReference> deletedOrderOptionsRefs = List();

  // TODO: Test this constructor
  _EditFoodItemState(DocumentReference reference){
    if(reference!=null){
      reference.get().then((onValue){
        FoodItem foodItem = FoodItem.fromSnapshot(onValue);
        setState(() {
          editableItem = foodItem;

          nameController.text = editableItem.name;
          descriptionController.text = editableItem.description;
          priceController.text = editableItem.price.toStringAsFixed(2);
        });

        reference.collection('options').getDocuments().then((optionsSnapshots){
          setState(() {
            optionsSnapshots.documents.forEach((snapshot){
              orderOptions.add(Option.fromSnapshot(snapshot));
            });
          });
        });
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(editableItem.name),),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: ListView(
            children: [
              _sectionTitle('Name of Dish'),
              _foodName(),
              _sectionTitle('Food Image'),
              _image(),
              _sectionTitle('Description'),
              _description(),
              _sectionTitle('Base Price'),
              _price(),
              _sectionTitle('Options'),
              Column(
                children: orderOptions.map((option) => _singleOptionView(option)).toList(),
              ),
              FlatButton(
                onPressed: (){
                  setState(() {
                    Option option = Option.newOption();
                    orderOptions.add(option);
                    _editOption(option);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(2, 2),
                        blurRadius: 5.0,
                      )
                    ],
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(Icons.add, size: 20, color: Theme.of(context).primaryColorDark,)
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text('Add Option', style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColorDark),),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _sectionTitle('Category'),
              _categories(),
              Padding(padding: EdgeInsets.all(20.0),),
              Container(
                height: 60.0,
                child: RaisedButton(
                  onPressed: createFoodItem,
                  color: Theme.of(context).primaryColorLight,
                  child: Text(
                    widget.reference==null?"Create Food Item":"Save Edits",
                    style: Theme.of(context).textTheme.subhead.apply(
                      color: Theme.of(context).primaryColorDark,
                      fontSizeFactor: 1.2
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal:  0.0),
      child: Text(
        '$text',
        style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5, color: Theme.of(context).primaryColorDark),
      ),
    );
  }

//  Future _showCurrentOrders() async {
//    // push a new route like you did in the last section
//    Navigator.of(context).pop(
//      MaterialPageRoute(
//        builder: (BuildContext context) {
//          return CurrentOrders();
//        },
//      ),
//    );
//  }

  Widget _foodName(){
    return TextField(
      controller: nameController,
      onSubmitted: (text){
        editableItem.name = text;
        nameController.text = text;
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

  Widget _image() {
    return FlatButton(
      onPressed: getImage,
      child: AspectRatio(
        aspectRatio: 1,
        child: addedImage != null? Image.file(addedImage, fit: BoxFit.cover,) : editableItem.image!=null? Services.foodImage(editableItem.image) : Container(color: Colors.grey, child: Icon(Icons.photo, color: Colors.black45,),),
      )
    );
  }

  void getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image != null) {
      setState(() {
        addedImage = image;
      });
    }
  }

  Widget _description() {
    return Builder(
      builder: (context){
        return TextField(
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          controller: descriptionController,
          onSubmitted: (text){
            editableItem.description = text;
            descriptionController.text = text;
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

  Widget _price(){
    return Container(
      child: TextField(
        controller: priceController,
        keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
        onSubmitted: (text) {
          editableItem.price = isNum(text)? double.parse(double.parse(text).toStringAsFixed(2)):0.0;
          setState(() {
            priceController.text = isNum(text)?double.parse(text).toStringAsFixed(2):'0.00';
          });
          return priceController.text = isNum(text)?double.parse(text).toStringAsFixed(2):'0.00';
        },
        decoration: InputDecoration(
          labelText: "You Recieve (\$)",
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),),
          labelStyle: TextStyle(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),
        ),
        style: TextStyle(color: editableItem.price<0.01?Colors.red:Colors.black),
      ),
    );
  }

  Widget _categories(){
    return Container(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: FoodItem.allCategories.map((name) =>
          Padding(
            padding: EdgeInsets.all(2.0),
            child: Padding(
              padding: EdgeInsets.all(editableItem.categories.contains(name)? 0:2),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: editableItem.categories.contains(name)? Theme.of(context).primaryColor : Colors.black26,
                    width: editableItem.categories.contains(name)? 4:2,
                  ),
                  color: editableItem.categories.contains(name)? Theme.of(context).primaryColorLight:Colors.transparent,
                ),
                child: FlatButton(
                  onPressed: (){
                    if(editableItem.categories.contains(name)){
                      editableItem.categories.remove(name);
                    }else{
                      editableItem.categories.add(name);
                    }
                    print(editableItem.categories);
                    setState((){});
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        '$name',
                        style: Theme.of(context).textTheme.subhead
                    ),
                  ),
                ),
              ),
            ),
          ),
        ).toList(),
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

  Widget _singleOptionView(Option option){
//    TextEditingController optionTitleController = TextEditingController();
//    optionTitleController.text = option.title;
//    List<TextEditingController> optionsControllers = List<TextEditingController>(option.options.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text('${option.title}', style: Theme.of(context).textTheme.subhead.apply(fontSizeFactor: 1.1, fontWeightDelta: 2)),
            ),
            IconButton(
              onPressed: (){
                _editOption(option);
              },
              icon: Icon(Icons.edit),
            ),
            IconButton(
              onPressed: (){
                _deleteOption(option);
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        Text('Maximum Selections: ${option.maxSelection}', style: Theme.of(context).textTheme.subhead, textAlign: TextAlign.right,),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: option.options.map((optionName, ) =>
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('$optionName', style: Theme.of(context).textTheme.subhead),
                  Text('\$ ${option.price[option.options.indexOf(optionName)].toStringAsFixed(2)}', style: Theme.of(context).textTheme.subhead)
                ],
              )
            ).toList(),
          ),
        )
      ],
    );
  }

  Future<void> _editOption(Option option) async {
    TextEditingController optionTitleController = TextEditingController(text: '${option.title}');
    List<TextEditingController> optionsControllers = option.options.map((indOption) => TextEditingController(text: indOption)).toList();
    List<TextEditingController> priceControllers = option.price.map((indPrice) => TextEditingController(text: indPrice.toStringAsFixed(2))).toList();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Option'),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: optionTitleController,
                  style: Theme.of(context).textTheme.subhead.apply(fontSizeFactor: 1.2, fontWeightDelta: 2),
                  onSubmitted: (text){
                    option.title = text;
                    setState(() {
                      optionTitleController.text = text;
                    });
                  },
                  onChanged: (text){
                    option.title = text;
                    setState(() {
                      optionTitleController.text = text;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0),
                    icon: Icon(Icons.title),

                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Text('Maximum Selections: ', style: Theme.of(context).textTheme.subhead),
                      ),
                      InkWell(
                        onTap: (){
                          setState(() {
                            option.maxSelection = option.maxSelection > 2? option.maxSelection - 1: 1;
                            Navigator.of(context).pop();
                            _editOption(option);
                          });
                        },
                        child: Icon(Icons.remove),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(option.maxSelection.toString(), style: Theme.of(context).textTheme.subhead),
                      ),
                      InkWell(
                        onTap: (){
                          setState(() {
                            option.maxSelection = option.maxSelection < option.options.length ? option.maxSelection + 1: option.options.length;
                            Navigator.of(context).pop();
                            _editOption(option);
                          });
                        },
                        child: Icon(Icons.add),
                      )
                    ],
                  ),
                ),
                Container(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        width: 200,
                        height: 165,
                        child: ListView.builder(
                          itemCount: option.options.length,
                          itemBuilder: (BuildContext buildContext, int i) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 100,
                                height: 35,
                                child: TextField(
                                  controller: optionsControllers[i],
                                  onSubmitted: (text){
                                    setState(() {
                                      optionsControllers[i].text = text;
                                      option.options[i] = text;
                                    });
                                  },
                                  onChanged: (text){
                                    setState(() {
                                      optionsControllers[i].text = text;
                                      option.options[i] = text;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: null,
                                    contentPadding: EdgeInsets.all(4.0),
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 4.0),),
                              Container(
                                width: 50,
                                height: 35,
                                child: TextField(
                                  keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                                  controller: priceControllers[i],
                                  onSubmitted: (text){
                                    setState(() {
                                      option.price[i] = isNum(text)? double.parse(double.parse(text).toStringAsFixed(2)):0.0;
                                      priceControllers[i].text = isNum(text)?double.parse(text).toStringAsFixed(2):'0.00';
                                    });
                                  },
                                  onChanged:  (text){
                                    setState(() {
                                      option.price[i] = isNum(text)? double.parse(double.parse(text).toStringAsFixed(2)):0.0;
                                      //TODO: Delete comment
                                      //priceControllers[i].text = isNum(text)?double.parse(text).toStringAsFixed(2):'0.00';
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: null,
                                    contentPadding: EdgeInsets.all(4.0),
                                    border: UnderlineInputBorder(),
                                  ),
                                ),
                              ),
                              Padding(padding: EdgeInsets.symmetric(horizontal: 4.0),),
                              InkWell(
                                onTap: (){
                                  setState(() {
                                    if(option.options.length == 1){
                                      Navigator.of(context).pop();
                                      _deleteOption(option);
                                      return;
                                    }
                                    option.options.removeAt(i);
                                    option.price.removeAt(i);
                                    option.maxSelection = option.maxSelection > option.options.length? option.options.length: option.maxSelection;
                                    Navigator.of(context).pop();
                                    _editOption(option);
                                  });
                                },
                                child: Icon(Icons.delete),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                ),
                Container(
                  height: 35.0,
                  child: FloatingActionButton(
                    tooltip: 'Add an Option',
                    onPressed: (){
                      setState(() {
                        option.options.add('New Option');
                        option.price.add(0.0);
                        option.maxSelection++;
                        Navigator.of(context).pop();
                        _editOption(option);
                      });
                    },
                    child: Icon(Icons.add),
                  ),
                ),
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

  void createFoodItem() async {

    if(editableItem.name == '' ||  editableItem.description == '' || editableItem.price < 0.01){
      print('Not Correct Values');
      _checkErrorsDialog();
      return;
    }

    if (addedImage != null){
      FirebaseStorage.instance.ref().child('foodpics').child(
          '${editableItem.image}.png').delete();
      editableItem.image = randomAlphaNumeric(10);
      FirebaseStorage.instance.ref().child('foodpics').child(
          '${editableItem.image}.png').putFile(addedImage);
    }

    if(editableItem.reference == null) {
      Future<DocumentReference> ref = editableItem.create();
      editableItem.reference = await ref;
    } else {
      editableItem.updateListingWithData(editableItem.reference);
    }

    orderOptions.forEach((option) {
      if (option.reference != null) {
        option.updateOption();
      }
      else{
        option.create(editableItem.reference);
      }
    });

    deletedOrderOptionsRefs.forEach((ref){
      ref.delete();
    });

    Navigator.of(context).pop();
  }

  Future<void> _checkErrorsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Check above fields for omissions or mistakes.'),
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

  Future<void> _deleteOption(Option option) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete the option: ${option.title}?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                setState(() {
                  if(option.reference != null)
                    deletedOrderOptionsRefs.add(option.reference);
                  option.deleteOption();
                  orderOptions.remove(option);
                });
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeDeleteImage(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image already selected.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Would you like to edit the image?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Delete'),
              onPressed: () {
                editableItem.image = null;
              },
            ),
            FlatButton(
              child: Text('Change'),
              onPressed: (){
                getImage();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
