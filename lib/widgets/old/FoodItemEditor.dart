//import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
//import 'dart:io';
//
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:image_picker/image_picker.dart';
//
//import 'package:cookt/models/foodItems/FoodItem.dart';
//import 'package:cookt/widgets/old/CurrentOrderSummary.dart';
//import 'package:cookt/widgets/old/MyFoodItems.dart';
//
//class FoodItemEditor extends StatefulWidget {
//  final DocumentReference reference;
//
//  FoodItemEditor({@required this.reference});
//
//  @override
//  _FoodItemEditorState createState() => _FoodItemEditorState();
//}
//
//class _FoodItemEditorState extends State<FoodItemEditor> {
//  // One TextEditingController for each form input:
//  FoodItem editableItem = FoodItem.newItem();
//  List<Image> images = List(6);
//  Map<int, File> changedImages = Map();
//  bool hasLoaded = false;
//
//  TextEditingController nameController = TextEditingController();
//  TextEditingController descriptionController = TextEditingController();
//  TextEditingController pricePaidController = TextEditingController();
//  TextEditingController priceReceivedController = TextEditingController();
//
//  @override
//  Widget build(BuildContext context) {
//    if(widget.reference!=null){
//      widget.reference.get().then((onValue){
//        if(!hasLoaded) {
//          FoodItem foodItem = FoodItem.fromSnapshot(onValue);
//          setState(() {
//            editableItem = foodItem;
//          });
//          for (int i = 0; i < foodItem.numImages; i++) {
//            FirebaseStorage.instance.ref().child("images").child(
//                "${foodItem.reference.documentID}-$i.png")
//                .getDownloadURL()
//                .then((imageUrl) {
//              Image image = Image.network(imageUrl.toString());
//              setState(() {
//                images[i] = image;
//              });
//            });
//          }
//          hasLoaded = true;
//        }
//      });
//    }
//    pricePaidController.text = editableItem.price.toStringAsFixed(2);
//    priceReceivedController.text = (editableItem.price*(1-FoodItem.cooktPercent)).toStringAsFixed(2);
//    nameController.text = editableItem.name;
//    descriptionController.text = editableItem.description;
//    // new page needs scaffolding!
//    return Scaffold(
//      appBar: AppBar(
//        title: Text("${widget.reference!=null?'Edit Food Item':'Add New'}"),
//        leading: IconButton(
//          icon: Icon(Icons.chevron_left),
//          iconSize: 40.0,
//          onPressed: _showCurrentOrders,
//        ),
//      ),
//      body: Container(
//        child: Padding(
//          padding: const EdgeInsets.symmetric(
//            vertical: 8.0,
//            horizontal: 16.0,
//          ),
//          child: ListView(
//            shrinkWrap: true,
//            children: [
//              _foodName(),
//              Padding(padding: EdgeInsets.all(4.0),),
//              _imagesScaffold(),
//              Padding(padding: EdgeInsets.all(4.0),),
//              _description(),
//              Padding(padding: EdgeInsets.all(4.0),),
//              _dineInAvailability(),
//              Padding(padding: EdgeInsets.all(4.0),),
//              _categories(),
//              Padding(padding: EdgeInsets.all(4.0),),
//              _price(),
//              Padding(padding: EdgeInsets.all(20.0),),
//              Container(
//                height: 60.0,
//                child: RaisedButton(
//                  onPressed: createFoodItem,
//                  color: Theme.of(context).cardColor,
//                  child: Text(widget.reference==null?"Create Food Item":"Save Edits"),
//                ),
//              )
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//
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
//
//  Widget _foodName(){
//    return TextField(
//      controller: nameController,
//      onSubmitted: (text){
//        editableItem.name = text;
//        nameController.text = text;
//        setState(() {});
//      },
//      decoration: InputDecoration(
//        labelText: "Food Name",
//        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.name==''?Colors.red:Theme.of(context).hintColor),),
//        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.name==''?Colors.red:Theme.of(context).hintColor),),
//        labelStyle: TextStyle(color: editableItem.name==''?Colors.red:Theme.of(context).hintColor),
//      ),
//    );
//  }
//
//  Widget _imagesScaffold(){
//    double spacing = 2.0;
//    return LayoutBuilder(builder: (content, constraints) {
//      Size size = Size(constraints.maxWidth, constraints.maxWidth);
//      return Center(
//        child: Container(
//          constraints: BoxConstraints(
//            maxWidth: size.width,
//            maxHeight: size.height,
//          ),
//          child: Column(
//            children: [
//              Expanded(
//                flex: 2,
//                child: Row(
//                  children: [
//                    _imageButton(0, flex: 2), // Largest Image
//                    Padding(padding: EdgeInsets.all(spacing),),
//                    Expanded(
//                      flex: 1,
//                      child: Column(
//                        children: [
//                          _imageButton(1), // Top Right
//                          Padding(padding: EdgeInsets.all(spacing),),
//                          _imageButton(2), // Mid Right
//                        ],
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//              Padding(padding: EdgeInsets.all(spacing),),
//              Expanded(
//                flex: 1,
//                child: Row(
//                  children: [
//                    _imageButton(5), // Bottom Right
//                    Padding(padding: EdgeInsets.all(spacing),),
//                    _imageButton(4), // Mid Bottom
//                    Padding(padding: EdgeInsets.all(spacing),),
//                    _imageButton(3), // Left Bottom
//                  ],
//                ),
//              ),
//            ],
//          ),
//        ),
//      );
//    });
//  }
//
//  Widget _imageButton(int index, {int flex = 1}) {
//    return Expanded(
//      flex: flex,
//      child: AspectRatio(
//        aspectRatio: 1,
//        child: Container(
//          decoration: BoxDecoration(
//            color: Colors.grey,
//            image: DecorationImage(
//              fit: BoxFit.cover,
//              image: images[index]!=null?images[index].image:NetworkImage('http://www.vikramhegde.org/transparent.png'),
//            ),
//          ),
//          child: FlatButton(
//            onPressed: (){
//              getImage(index: index);
//            },
//            child: images[index]!=null?null:Icon(Icons.photo,color: Colors.black45,),
//          ),
//        ),
//      )
//    );
//  }
//
//  void getImage({@required int index}) async {
//    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
//    if(image != null) {
//      print('Changing at $index out of ${editableItem.numImages} total Images');
//      setState(() {
//        images[index > editableItem.numImages ? editableItem.numImages : index] = Image.file(image);
//      });
//      changedImages[index>editableItem.numImages?editableItem.numImages:index] = image;
//      editableItem.numImages+=index>=editableItem.numImages?1:0;
//      print('Number of images: ${editableItem.numImages}');
//    }
//  }
//
//  Widget _description() {
//    return Builder(
//      builder: (context){
//        return TextField(
//          keyboardType: TextInputType.multiline,
//          maxLines: 5,
//          controller: descriptionController,
//          onSubmitted: (text){
//            editableItem.description = text;
//            descriptionController.text = text;
//            setState(() {});
//          },
//          textInputAction: TextInputAction.done,
//          decoration: InputDecoration(
//            labelText: "Food Description",
//            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: editableItem.description==''?Colors.red:Theme.of(context).hintColor),),
//            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: editableItem.description==''?Colors.red:Theme.of(context).hintColor),),
//            labelStyle: TextStyle(color: editableItem.description==''?Colors.red:Theme.of(context).hintColor),
//          ),
//
//        );
//      },
//    );
//  }
//
//  Widget _price(){
//    return Container(
//      height: 40.0,
//      child: Builder(
//        builder: (context){
//          return Row(
//            children: <Widget>[
//              Expanded(
//                flex: 1,
//                child: TextField(
//                  controller: pricePaidController,
//                  keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
//                  onSubmitted: (text) {
//                    editableItem.price = isNum(text)?double.parse(text):0.0;
//                    setState(() {});
//                    priceReceivedController.text = isNum(text)?(double.parse(text)*(1-FoodItem.cooktPercent)).toStringAsFixed(2):'0.00';
//                    return pricePaidController.text = isNum(text)?double.parse(text).toStringAsFixed(2):'0.00';
//                  },
//                  decoration: InputDecoration(
//                      labelText: "Customer Pays (\$)",
//                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),),
//                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),),
//                      labelStyle: TextStyle(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),
//                  ),
//                  style: TextStyle(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),
//                ),
//              ),
//              Padding(padding: EdgeInsets.all(8.0),),
//              Expanded(
//                flex: 1,
//                child: TextField(
//                  controller: priceReceivedController,
//                  keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
//                  onSubmitted: (text) {
//                    editableItem.price = isNum(text)? double.parse(text)*(1+FoodItem.cooktPercent):0.0;
//                    setState(() {});
//                    pricePaidController.text = isNum(text)?(double.parse(text)*(1+FoodItem.cooktPercent)).toStringAsFixed(2):'0.00';
//                    return priceReceivedController.text = isNum(text)?double.parse(text).toStringAsFixed(2):'0.00';
//                  },
//                  decoration: InputDecoration(
//                    labelText: "You Recieve (\$)",
//                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),),
//                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),),
//                    labelStyle: TextStyle(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),
//                  ),
//                  style: TextStyle(color: editableItem.price<0.01?Colors.red:Theme.of(context).hintColor),
//                ),
//              )
//
//            ],
//          );
//        },
//      ),
//    );
//  }
//
//  Widget _dineInAvailability(){
//    return Container(
//      height: 40.0,
//      child: Row(
//        children: <Widget>[
//          Expanded(
//            flex: 10,
//            child: Builder(
//              builder:(context){
//                return Text(
//                  'Dine in Available',
//                  style: Theme.of(context).textTheme.subhead,
//                );
//              },
//            )
//
//          ),
//          Expanded(
//            flex: 2,
//            child: Switch.adaptive(
//              value: editableItem.dineInAvailable,
//              onChanged: (value) => setState(() => editableItem.dineInAvailable = value)
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//
//  Widget _categories(){
//    bool leftCol = false;
//    List<Widget> left = [];
//    List<Widget> right = [];
//
//    for(String name in FoodItem.allCategories){
//      Widget button = Container(
//        height: 50.0,
//        child: FlatButton(
//          onPressed: (){
//            if(editableItem.categories.contains(name)){
//              editableItem.categories.remove(name);
//            }else{
//              editableItem.categories.add(name);
//            }
//            print(editableItem.categories);
//            setState((){});
//            setState((){});
//          },
//          splashColor: editableItem.categories.contains(name)?Theme.of(context).splashColor:Colors.greenAccent,
//          child: Text(
//            '$name',
//            style: Theme.of(context).textTheme.subhead.apply(
//              color: editableItem.categories.contains(name)?Colors.green:Theme.of(context).textTheme.subhead.color,
//              fontWeightDelta: editableItem.categories.contains(name)?2:0,
//            ),
//          ),
//        ),
//      );
//      if(leftCol){
//        left.add(button);
//      }else{
//        right.add(button);
//      }
//      leftCol = !leftCol;
//    }
//
//    return Container(
//      child: Row(
//        children: <Widget>[
//          Flexible(
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.stretch,
//              children: left,
//            ),
//          ),
//          Flexible(
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.stretch,
//              children: right,
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//
//  bool isNum(String text){
//    try{
//      var value = double.parse(text);
//    } on FormatException {
//      return false;
//    }
//    return true;
//  }
//
//  void createFoodItem() async {
//    // update/upload pictures
//    // update/create fooditem
//
//    if(editableItem.name == '' ||  editableItem.description == '' || editableItem.price < 0.01){
//      print('Not Correct Values');
//      _checkErrors();
//      return;
//    }
//
//    if(widget.reference == null) {
//      Future<DocumentReference> ref = editableItem.createListing();
//      editableItem.reference = await ref;
//    } else {
//      print('Updating with a change');
//      editableItem.updateListingWithData(editableItem.reference);
//    }
//
//    changedImages.forEach((i, imageFile) {
//      print(i);
//      FirebaseStorage.instance.ref().child('images').child('${editableItem.reference.documentID}-$i.png').putFile(imageFile);
//    });
//    Navigator.of(context).pop(
//      MaterialPageRoute(
//        builder: (BuildContext context) {
//          return MyFoodItems();
//        },
//      ),
//    );
//  }
//
//  Future<void> _checkErrors() async {
//    return showDialog<void>(
//      context: context,
//      barrierDismissible: false, // user must tap button!
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: Text('Incorrect Parameters'),
//          content: SingleChildScrollView(
//            child: ListBody(
//              children: <Widget>[
//                Text('Check above fields for omissions.'),
//              ],
//            ),
//          ),
//          actions: <Widget>[
//            FlatButton(
//              child: Text('Ok'),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }
//}