import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'package:cookt/models/foodItems/Option.dart';
import 'package:cookt/models/foodItems/Review.dart';

import 'package:cookt/models/orders/Selection.dart';
import 'package:cookt/models/orders/Order.dart';
import 'package:cookt/models/orders/Item.dart';

import 'package:cookt/models/DatabaseIntegrator.dart';

import 'ReviewList.dart';

class FoodItemView extends StatefulWidget {
  final DocumentReference reference;

  FoodItemView({@required this.reference});

  @override
  _FoodItemViewState createState() => _FoodItemViewState(reference);
}

class _FoodItemViewState extends State<FoodItemView> {

  // TODO: Remove all direct data requests from the view classes
  // TODO:  Find all view classes and delete firebase imports
  // TODO:  Go to all model classes and add helper methods that
  // TODO:    interface with the database to do what the orignal code was doing.

  // TODO: Index all first and last names to their UID
  // Firebase: Access at 'vikram' and get a list of UID's to query food items with

  bool hasOrdered = false;

  ScrollController scroller = ScrollController();

  // One TextEditingController for each form input:
  FoodItem foodItem = FoodItem.newItem();
  List<Widget> images = [];
  Map<String, Widget> loadedImages = Map();
  List<Review> reviews = [];
  List<Option> orderOptions = [];
  List<Selection> itemSelections = [];

  double price = 0.0;
  int quantity = 1; // TODO: Implement Quantity

  TextEditingController reviewController = TextEditingController();
  int myRating = 0;

  GoogleMapController mapController;

  LatLng myCoords = null;
  LatLng cookCoords = null;

  _FoodItemViewState(DocumentReference reference){

    scroller = ScrollController();
    scroller.addListener(scrolled);

    images = [Container(
      color: Colors.grey,
      child: Icon(Icons.photo, color: Colors.black45,),
    )];

    if(reference!=null){
      reference.get().then((onValue){
          FoodItem foodItemLoaded = FoodItem.fromSnapshot(onValue);
          setState(() {
            foodItem = foodItemLoaded;
          });

          loadReviews(reference);
          checkIfOrdered();
          loadLocation();

          price = foodItem.price;

          images = foodItem.images.map((img) => Container(
            color: Colors.grey,
            child: loadedImages[img] != null? loadedImages[img]: Icon(Icons.photo, color: Colors.black45,),
          )).toList();

          foodItem.images.forEach((ref){
            FirebaseStorage.instance.ref().child("foodpics").child(
                "$ref.png")
                .getDownloadURL()
                .then((imageUrl) {
              Image image = Image.network(imageUrl.toString(),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              );
              int index = foodItem.images.indexOf(ref);
              setState(() {
                loadedImages[ref] = image;
                images = foodItem.images.map((img) => Container(
                  color: Colors.grey,
                  child: loadedImages[img] != null? loadedImages[img]: Icon(Icons.photo, color: Colors.black45,),
                )).toList();
                print("Found and inserted image. $loadedImages");
              });
            });
          });

          reference.collection('options').getDocuments().then((optionsSnapshots){
            optionsSnapshots.documents.forEach((snapshot){
              orderOptions.add(Option.fromSnapshot(snapshot));
            });
            itemSelections = orderOptions.map((option) => Selection.from(option.title)).toList();
          });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    updateMap();
    return Scaffold(
      appBar: AppBar(title: Text(foodItem.name),),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: ListView(
          shrinkWrap: true,
          controller: scroller,
          children: [
            Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0), child:
            Text('Food Pics', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
            _imagesScroll(),
            Padding(padding: EdgeInsets.all(8.0), child:
            Text('Description', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
            _description(),
            Padding(padding: EdgeInsets.all(8.0), child:
            Text('Details', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _rating(),
                _price(),
              ],
            ),
            Padding(padding: EdgeInsets.all(8.0), child:
            Text('Map', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
            _map(),
            Padding(padding: EdgeInsets.all(8.0), child:
            Text('Categories', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
            _categories(),
            Padding(padding: EdgeInsets.all(8.0), child:
            Text('Order Options', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
            _optionSelect(),
            Padding(padding: EdgeInsets.all(8.0), child:
            Text('Rate/Review', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
            _rateAndReview(),
            Padding(padding: EdgeInsets.all(8.0), child:
            Text('Other Reviews', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5),),),
            ReviewList(reviews),
            Padding(padding: EdgeInsets.all(50.0),),
          ],
        ),
//
      ),
      floatingActionButton: Stack(
          alignment: Alignment.centerRight,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight.withAlpha(150),
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(5.0),
              ),
              width: 175,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: orderItem,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('\$${price<=0? '\$\$.\$\$': price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.subtitle.apply(fontSizeFactor: 2),),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: FloatingActionButton(
                elevation: 10,
                onPressed: orderItem,
                foregroundColor: Theme.of(context).primaryColorLight,
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Icons.shopping_cart),
              ),
            ),
          ],
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void checkIfOrdered() async {
    await for (QuerySnapshot snapshots in Firestore.instance
        .collection("orders")
        .where('customerID', isEqualTo: 'usercustomer')
        .where('cookID', isEqualTo: '${foodItem.uid}')
        .where('active', isEqualTo: false)
        .snapshots().asBroadcastStream()) {
      for (DocumentSnapshot snapshot in snapshots.documents) {
        await for (QuerySnapshot itemSnaps in snapshot
            .reference.collection('items')
            .where('foodID', isEqualTo: foodItem.reference.documentID)
            .snapshots().asBroadcastStream()){
          for (DocumentSnapshot itemSnap in itemSnaps.documents) {
            setState(() {
              hasOrdered = true;
            });
          }
        }
      }
    }
  }

  void scrolled(){
    updateMap();
  }

  void loadLocation() async{
    var location = new Location();
    try {
      Map<String, double> currentLocation = await location.getLocation();
      if(myCoords==null || (myCoords.latitude-currentLocation["latitude"]).abs()>=0.0001 || (myCoords.longitude-currentLocation["longitude"]).abs()>=0.0001)
        setState(() {
          myCoords = LatLng(currentLocation["latitude"], currentLocation["longitude"]);
        });
      updateMap();
    } on Exception {}

    DatabaseIntegrator.loc(foodItem.uid).then((val) => setState(() {
      cookCoords = val;
      updateMap();
    }));
  }

  void updateMap(){
    if(mapController == null || cookCoords == null) {
      return;
    }

    mapController.addMarker(
      MarkerOptions(
        position: cookCoords,
      ),
    );
    if(myCoords == null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: cookCoords, zoom: 15)
        )
      );
      return;
    }
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(myCoords.latitude<cookCoords.latitude?myCoords.latitude:cookCoords.latitude,
                            myCoords.longitude<cookCoords.longitude?myCoords.longitude:cookCoords.longitude),
          northeast: LatLng(myCoords.latitude>cookCoords.latitude?myCoords.latitude:cookCoords.latitude,
                            myCoords.longitude>cookCoords.longitude?myCoords.longitude:cookCoords.longitude),
        ),
        80.0,
      ),
    );
  }

  void loadCookLocation(FoodItem foodItem){
    FirebaseDatabase.instance.reference().child(foodItem.uid).child('userinfo').onValue.listen((onValue){
      var data = onValue.snapshot.value;
      cookCoords = LatLng(data['lat'], data['long']);
      updateMap();
    });
  }

  void loadReviews(DocumentReference ref) async {
    await for (QuerySnapshot snapshots in ref
        .collection("reviews")
        .snapshots().asBroadcastStream()) {
      for (int i = 0; i < snapshots.documentChanges.length; i++) {
        Review review = Review.fromSnapshot(snapshots.documents.elementAt(i));
        if (!reviews.contains(review)){
          setState(() {
            reviews.add(review);
            if(review.userid=='usercustomer'){
              reviewController.text = review.review;
              myRating = review.rating;
            }
          });
        }else{
          setState(() {
            reviews.remove(review);
            reviews.add(review);
          });
        }
      }
    }
  }

  void rateAndReview(){
    if(!hasOrdered){
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Order before reviewing'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Please order before you review the food item. This is to ensure fair reviews that are based on real experiences.'),
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
      return;
    }

    for(Review review in reviews){
      if(review.userid == 'usercustomer'){
        review.updateReview(reviewController.text, myRating);
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Review Updated'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Your review has been updated.'),
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
        return;
      }
    }
    Review review = Review.from(myRating, reviewController.text);
    review.create(foodItem.reference);
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Review Created'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your review has been created.'),
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

  void orderItem() async{
    // Check whether order exists
    // Add to Existing Order or Create new Order and add the Item
    // Add all Selections to the Item. If the selections is [], add 'NONE'
    // Add the Price of additions to the ItemPrice

    // Check if online (May fail if google.com is down)
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Firestore.instance.collection('orders')
            .where('cookID', isEqualTo: foodItem.uid)
            .where('customerID', isEqualTo: 'usercustomer', )
            .where('status', isEqualTo: 'PENDING')
            .where('active', isEqualTo: true).getDocuments().then((querySnapshot){
              if(querySnapshot != null && querySnapshot.documents != null && querySnapshot.documents.length > 0) {
                // Found Order

                Order order = Order.fromSnapshot(querySnapshot.documents.first);
                Item item = Item.from(foodItem.reference.documentID, price, quantity);
                order.addItem(item, itemSelections);
              }else{
                //Create Order
                Order order = Order.newOrder(foodItem.uid);
                Item item = Item.from(foodItem.reference.documentID, price, quantity);
                order.create(item: item, selections: itemSelections);
              }

        });
      }
    } on SocketException catch (_) {
      print('Not Connected');
    }
  }

  Widget _imagesScroll() {
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
      height: screenSize.width,
      child: PageView(
        scrollDirection: Axis.horizontal,
        children: images,
      ),
    );
  }

  Widget _description() {
    return Builder(
      builder: (context){
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '${foodItem.description}',
                style: Theme.of(context).textTheme.subhead,
              ),
            ),
          )
        );
      },
    );
  }

  Widget _rating(){
    double rating = 0;
    for(Review review in reviews){
      rating += review.rating;
    }
    return Center(
      child: reviews.length>0?Row(
        children: <Widget>[
          Text('Rating: ${(rating/reviews.length.toDouble()).toStringAsFixed(2)}', style: Theme.of(context).textTheme.subhead,),
          Padding(padding: EdgeInsets.all(2.0),),
          Icon(Icons.star_border,size: 15.0,),
          Padding(padding: EdgeInsets.all(2.0),),
          Text('(${reviews.length} rating${reviews.length==1?'':'s'})', style: Theme.of(context).textTheme.subhead,),
        ],
      ):Text('No Ratings Available', style: Theme.of(context).textTheme.subhead,),
    );
  }

  Widget _price(){
    return Center(
      child: Text('Base Price: \$${foodItem.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.subhead,),
    );
  }

  Widget _map(){
    return Container(
      height: 400.0,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        // TODO: Change these map options
        options: GoogleMapOptions(
          mapType: MapType.normal,
          myLocationEnabled: true,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: false,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }

  Widget _categories(){
    bool leftCol = true;
    List<Widget> left = [];
    List<Widget> right = [];

    for(String name in foodItem.categories){
      Widget categoryText = Container(
        height: 50.0,
        child: Center(
          child: Text(
            '$name',
            style: Theme.of(context).textTheme.subhead.apply(
            ),
          ),
        ),
      );
      if(leftCol){
        left.add(categoryText);
      }else{
        right.add(categoryText);
      }
      leftCol = !leftCol;
    }

    if(left.length != right.length)
      right.add(Container(height: 50.0,));

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

  Widget _optionSelect(){
    // Display OrderOptions
    // Add selection to itemSelections
    // Update price upon selection

    return Container(
      child: Column(
        children: orderOptions.map((option) => Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: _singleOptionSelector(option),
        )).toList(),
      ),
    );
  }

  Widget _singleOptionSelector(Option option){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text('${option.title} ${option.options.length == option.maxSelection? '': '(Max: ${option.maxSelection})'}', style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.2),),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: option.options.map((optionName) => FlatButton(
                onPressed: (){
                  Selection selection = itemSelections[orderOptions.indexOf(option)];
                  int index = selection.selections.indexOf(optionName);
                  if(index >= 0)
                    setState(() {
                      selection.selections.removeAt(index);
                      price -= selection.prices.removeAt(index);
                    });
                  else if(selection.selections.length < option.maxSelection)
                    setState(() {
                      selection.selections.add(optionName);
                      selection.prices.add(option.price[option.options.indexOf(optionName)]);
                      price += option.price[option.options.indexOf(optionName)];
                    });
                  print(selection);
                },
                child: Text('$optionName ${option.price[option.options.indexOf(optionName)]<=0? '': '(+\$${option.price[option.options.indexOf(optionName)].toStringAsFixed(2)})'}', style: Theme.of(context).textTheme.subhead.apply(color: itemSelections[orderOptions.indexOf(option)].selections.contains(optionName)? Colors.green: Colors.black),),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rateAndReview(){
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: FlatButton(
                highlightColor: Colors.transparent,
                onPressed: (){
                  setState(() {
                    myRating = 1;
                  });
                },
                child: Icon(myRating>=1?Icons.star:Icons.star_border, size: 50.0),
              ),
            ),
            Flexible(
              child: FlatButton(
                highlightColor: Colors.transparent,
                onPressed: (){
                  setState(() {
                    myRating = 2;
                  });
                },
                child: Icon(myRating>=2?Icons.star:Icons.star_border, size: 50.0),
              ),
            ),
            Flexible(
              child: FlatButton(
                highlightColor: Colors.transparent,
                onPressed: (){
                  setState(() {
                    myRating = 3;
                  });
                },
                child: Icon(myRating>=3?Icons.star:Icons.star_border, size: 50.0),
              ),
            ),
            Flexible(
              child: FlatButton(
                highlightColor: Colors.transparent,
                onPressed: (){
                  setState(() {
                    myRating = 4;
                  });
                },
                child: Icon(myRating>=4?Icons.star:Icons.star_border, size: 50.0),
              ),
            ),
            Flexible(
              child: FlatButton(
                highlightColor: Colors.transparent,
                onPressed: (){
                  setState(() {
                    myRating = 5;
                  });
                },
                child: Icon(myRating>=5?Icons.star:Icons.star_border, size: 50.0),
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.all(8.0),),
        TextField(
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          controller: reviewController,
          onSubmitted: (text){
            setState(() {
              reviewController.text = text;
            });
          },
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: "My Review",
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
            labelStyle: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
        Padding(padding: EdgeInsets.all(2.0),),
        RaisedButton(
          padding: EdgeInsets.all(8.0),
          onPressed: myRating<=0?null:(){
            rateAndReview();
          },
          child: Text('${myRating<=0?'Tap Stars to Rate':'${reviewController.text==''?'Rate':'Rate and Review'}'}'),
        ),
      ],
    );
  }
}