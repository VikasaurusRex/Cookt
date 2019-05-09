import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/models/foodItems/Option.dart';


class EditFoodItem extends StatefulWidget {
  final DocumentReference reference;

  EditFoodItem({@required this.reference});

  @override
  _EditFoodItemState createState() => _EditFoodItemState();
}

class _EditFoodItemState extends State<EditFoodItem> {
  // One TextEditingController for each form input:
  FoodItem editableItem = FoodItem.newItem();
  List<Image> images = List(6);
  Map<int, File> changedImages = Map();
  bool hasLoaded = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  List<Option> orderOptions = List();

  @override
  Widget build(BuildContext context) {
    if(widget.reference!=null){
      widget.reference.get().then((onValue){
        if(!hasLoaded) {
          FoodItem foodItem = FoodItem.fromSnapshot(onValue);
          setState(() {
            editableItem = foodItem;
          });
          for (int i = 0; i < foodItem.numImages; i++) {
            FirebaseStorage.instance.ref().child("foodpics").child(
                "${foodItem.reference.documentID}-$i.png")
                .getDownloadURL()
                .then((imageUrl) {
              Image image = Image.network(imageUrl.toString());
              setState(() {
                images[i] = image;
              });
            });
          }
          widget.reference.collection('options').getDocuments().then((optionsSnapshots){
            optionsSnapshots.documents.forEach((snapshot){
              print(snapshot);
              orderOptions.add(Option.fromSnapshot(snapshot));
            });
          });
          hasLoaded = true;
        }
      });
    }

    nameController.text = editableItem.name;
    descriptionController.text = editableItem.description;
    priceController.text = editableItem.price.toStringAsFixed(2);

    return Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: ListView(
            children: [
              Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal:  0.0), child:
              Text('Name of Dish', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
              _foodName(),
              Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal:  0.0), child:
              Text('Images', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
              _imagesScaffold(),
              Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal:  0.0), child:
              Text('Description', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
              _description(),
              Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal:  0.0), child:
              Text('Category', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
              _categories(),
              Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal:  0.0), child:
              Text('Base Price', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
              _price(),
              Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal:  0.0), child:
              Text('Options', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
              Column(
                children: orderOptions.map((option) => _singleOptionEditor(option)).toList(),
              ),
              Container(
                height: 35.0,
                child: FloatingActionButton(
                  tooltip: 'Add an Option',
                  onPressed: (){
                    setState(() {
                      Option option = Option.newOption();
                      orderOptions.add(option);
                      _editOption(option);
                    });
                  },
                  child: Icon(Icons.add),
                ),
              ),
              Padding(padding: EdgeInsets.all(20.0),),
              Container(
                height: 60.0,
                child: RaisedButton(
                  onPressed: createFoodItem,
                  color: Theme.of(context).cardColor,
                  child: Text(widget.reference==null?"Create Food Item":"Save Edits"),
                ),
              ),
            ],
          ),
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

  Widget _imagesScaffold(){
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
                image: images[index]!=null?images[index].image:NetworkImage('http://www.vikramhegde.org/transparent.png'),
              ),
            ),
            child: FlatButton(
              onPressed: (){
                getImage(index: index);
              },
              child: images[index]!=null?null:Icon(Icons.photo,color: Colors.black45,),
            ),
          ),
        )
    );
  }

  //TODO: Remove Images
  void getImage({@required int index}) async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image != null) {
      print('Changing at $index out of ${editableItem.numImages} total Images');
      setState(() {
        images[index > editableItem.numImages ? editableItem.numImages : index] = Image.file(image);
      });
      changedImages[index>editableItem.numImages?editableItem.numImages:index] = image;
      editableItem.numImages+=index>=editableItem.numImages?1:0;
      print('Number of images: ${editableItem.numImages}');
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

  Widget _singleOptionEditor(Option option){
//    TextEditingController optionTitleController = TextEditingController();
//    optionTitleController.text = option.title;
//    List<TextEditingController> optionsControllers = List<TextEditingController>(option.options.length);
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text('${option.title}', style: Theme.of(context).textTheme.subhead.apply(fontSizeFactor: 1.1)),
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
          content: Column(
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
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
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
                    width: 250,
                    height: 165,
                    child: ListView.builder(
                      itemCount: option.options.length,
                      itemBuilder: (BuildContext buildContext, int i) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 150,
                            height: 35,
                            child: TextField(
                              controller: optionsControllers[i],
                              onSubmitted: (text){
                                option.options[i] = text;
                                setState(() {
                                  optionsControllers[i].text = text;
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
                                option.price[i] = isNum(text)? double.parse(double.parse(text).toStringAsFixed(2)):0.0;
                                setState(() {
                                  priceControllers[i].text = isNum(text)?double.parse(text).toStringAsFixed(2):'0.00';
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

    if(widget.reference == null) {
      Future<DocumentReference> ref = editableItem.createListing();
      editableItem.reference = await ref;
    } else {
      print('Updating with a change');
      editableItem.updateListingWithData(editableItem.reference);
    }

    changedImages.forEach((i, imageFile) {
      print(i);
      FirebaseStorage.instance.ref().child('foodpics').child('${editableItem.reference.documentID}-$i.png').putFile(imageFile);
    });

    orderOptions.forEach((option) {
      if (option.reference != null) {
        option.updateOption();
      }
      else{
        option.createOption(editableItem.reference.collection('options'));
      }
    });

    //TODO: Delete Comment
//    Navigator.of(context).pop(
//      MaterialPageRoute(
//        builder: (BuildContext context) {
//          return MyFoodItems();
//        },
//      ),
//    );
  }

  Future<void> _checkErrorsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
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

}


// TODO: delete
//decoration: BoxDecoration(
//        border: Border.all(color: Colors.grey),
//        borderRadius: BorderRadius.circular(5.0),
//      ),