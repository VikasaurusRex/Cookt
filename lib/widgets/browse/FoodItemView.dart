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
import 'package:cookt/models/User.dart';

import 'package:cookt/widgets/search/CategoryTile.dart';
import 'package:cookt/widgets/search/Search.dart';
import 'package:cookt/widgets/personal/StoreOverview.dart';
import 'ReviewList.dart';

class FoodItemView extends StatefulWidget {
  final DocumentReference reference;
  final User cook;

  FoodItemView({@required this.reference, this.cook});

  @override
  _FoodItemViewState createState() => _FoodItemViewState(reference);
}

class _FoodItemViewState extends State<FoodItemView> {

  // TODO: Remove all direct data requests from the view classes
  // TODO:  Find all view classes and delete firebase imports
  // TODO:  Go to all model classes and add helper methods that
  // TODO:    interface with the database to do what the original code was doing.
  // TODO: Add price when quantity changes

  // TODO: Remove buy button when far away

  bool hasOrdered = false;
  bool canOrder = false;

  ScrollController scroller = ScrollController();

  // One TextEditingController for each form input:
  FoodItem foodItem = FoodItem.newItem();
  Map<String, Widget> loadedImages = Map();
  List<Review> reviews = [];
  List<Option> orderOptions = [];
  List<Selection> itemSelections = [];

  double price = 0.0;
  int quantity = 1;

  TextEditingController reviewController = TextEditingController();
  int myRating = 0;

  GoogleMapController mapController;

  LatLng myCoords = null;
  LatLng cookCoords = null;

  _FoodItemViewState(DocumentReference reference){

    scroller = ScrollController();
    scroller.addListener(updateMap);


    if(reference!=null){
      reference.get().then((onValue){
          FoodItem foodItemLoaded = FoodItem.fromSnapshot(onValue);
          setState(() {
            foodItem = foodItemLoaded;
          });

          loadReviews(reference);
          checkIfOrdered();
          canOrder = checkIfAvailable();
          loadLocation();

          price = foodItem.price;

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
      body: ListView(
          shrinkWrap: true,
          controller: scroller,
          children: [
            _foodImage(),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(5.0)
                ),
                child: _storeOverviewTile(),
              ),
            ),
            _paddedLabel('Description'),
            _description(),
            //_paddedLabel('Map'),
            //_map(),
            _paddedLabel('Categories'),
            _categories(),
            _paddedLabel('Order Options'),
            _optionSelect(),
            _paddedLabel('Quantity'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _quantityAdjustor(),
            ),





            Padding(
              padding: EdgeInsets.fromLTRB(8, 35, 8, 10),
              child: Container(
                height: 1,
                color: Colors.black12,
              ),
            ),
            _paddedLabel('Details'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _rating(),
                _price(),
              ],
            ),
            _paddedLabel('Rate/Review'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _rateAndReview(),
            ),
            _paddedLabel('Other Reviews'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ReviewList(reviews),
            ),
          ],
        ),
      floatingActionButton: canOrder?_orderButton():Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void checkIfOrdered() async {
    Firestore.instance.collection("orders").where('customerID', isEqualTo: 'usercustomer').where('cookID', isEqualTo: '${foodItem.uid}').where('active', isEqualTo: false).getDocuments().then((snapshots) {
      snapshots.documents.forEach((snapshot) {
        snapshot.reference.collection('items').where('foodID', isEqualTo: foodItem.reference.documentID).getDocuments().then((itemSnaps){
          itemSnaps.documents.forEach((snap) {
            setState(() {
              hasOrdered = true;
            });
          });
        });
      });
    });
  }

  bool checkIfAvailable(){
    if(foodItem.isHosting)
      return true;
    return false;
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
      cookCoords = LatLng(val.latitude, val.longitude);
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
    foodItem.reference.get().then((snap){
      FoodItem tempItem = FoodItem.fromSnapshot(snap);
      if(tempItem.isHosting) {
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
            Navigator.of(context).pop();
          }else{
            //Create Order
            Order order = Order.newOrder(foodItem.uid);
            Item item = Item.from(foodItem.reference.documentID, price, quantity);
            order.create(item: item, selections: itemSelections);
            Navigator.of(context).pop();
          }

        });
      }else{
        _notAvailable();
      }
    });
  }

  Future<void> _notAvailable() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Item Not Available'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This food item is not available. Please check back later.'),
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

  Widget _paddedLabel(String text){
    return Padding(padding: EdgeInsets.fromLTRB(8.0, 20, 8.0, 8.0), child:
    Text(text, style: Theme.of(context).textTheme.subhead.apply(fontWeightDelta: 2, fontSizeFactor: 1.5, color: Theme.of(context).primaryColorDark),),);
  }

  Widget _orderButton(){
    return Stack(
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
              child: Text('\$${price<=0? '\$\$.\$\$': (price*quantity).toStringAsFixed(2)}', style: Theme.of(context).textTheme.subtitle.apply(fontSizeFactor: 2),),
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
    );
  }

  Widget _foodImage() {
    final Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Column(
            children: <Widget>[
              InkWell(
                onTap:  widget.cook == null? null:(){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return StoreOverview(widget.cook);
                      },
                    ),
                  );
                },
                child: AspectRatio(
                  aspectRatio: 2,
                  child: DatabaseIntegrator.storefrontImage(foodItem.uid),
                ),
              ),
              AspectRatio(
                aspectRatio: 2,
                child: Container(),//color: Colors.red,),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: AspectRatio(
              aspectRatio: 1,
              child: DatabaseIntegrator.foodImage(foodItem.image),
            ),
          )
        ],
      ),
    );
  }

  Widget _storeOverviewTile(){
      return widget.cook != null? InkWell(
        onTap: (){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return StoreOverview(widget.cook);
              },
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            // Box decoration takes a gradient
//            gradient: LinearGradient(
//              // Where the linear gradient begins and ends
//              begin: Alignment.bottomCenter,
//              end: Alignment.topCenter,
//              // Add one stop for each color. Stops should increase from 0 to 1
//              stops: [0, 0.5],
//              colors: [
//                // Colors are easy thanks to Flutter's Colors class.
//                Colors.black54,
//                Colors.black45
//              ],
//            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(750),
                  ),
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(750),
                    child: DatabaseIntegrator.userImage('usercook'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 8, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      widget.cook.kitchenname == null?Container():
                        Text(
                          widget.cook.kitchenname,
                          style: Theme.of(context).textTheme.headline.apply(
                            fontWeightDelta: 2,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      widget.cook.about == null?Container():
                        Container(
                          width: 250,
                          child: Text(
                            widget.cook.about,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.subhead.apply(
                              color: Theme.of(context).primaryColorDark
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Text(
                        'By ${widget.cook.firstname} ${widget.cook.lastname}',
                        style: Theme.of(context).textTheme.subhead.apply(
                          color: Theme.of(context).primaryColorDark
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ):Container();
  }

  Widget _description() {
    return Builder(
      builder: (context){
        return Container(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '${foodItem.description}',
                style: Theme.of(context).textTheme.subhead,
                textAlign: TextAlign.center,
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
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: foodItem.categories.map((cat) => Padding(padding: EdgeInsets.symmetric(horizontal: 4.0),child: Container(width: 150, child: CategoryTile(cat, (){

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return Search(isSearching: true, searchFieldText: cat,);
              },
            ),
          );
        })))).toList()
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
//      decoration: BoxDecoration(
//        border: Border.all(color: Colors.grey),
//        borderRadius: BorderRadius.circular(0.0),
//      ),
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${option.title}',
                    style: Theme.of(context).textTheme.subhead.apply(
                      fontWeightDelta: 2,
                      fontSizeFactor: 1.2,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  option.maxSelection != 1 && option.maxSelection != option.options.length?

                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child:Text(
                      'Select up to ${option.maxSelection}.',
                      style: Theme.of(context).textTheme.subhead.apply(
                        fontWeightDelta: 1,
                        fontSizeFactor: 0.8,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ):Container(),
                ],
              )
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: option.options.map((optionName){
                  Selection selection = itemSelections[orderOptions.indexOf(option)];
                  return FlatButton(
                    color: selection.selections.contains(optionName)? Theme.of(context).primaryColorLight: Colors.transparent,
                    onPressed: (){
                      int index = selection.selections.indexOf(optionName);
                      if(index >= 0) { // contained
                        setState(() {
                          selection.selections.removeAt(index);
                          price -= selection.prices.removeAt(index);
                        });
                      }else{
                        if (selection.selections.length < option.maxSelection) {
                          setState(() {
                            selection.selections.add(optionName);
                            selection.prices.add(
                                option.price[option.options.indexOf(
                                    optionName)]);
                            price +=
                            option.price[option.options.indexOf(optionName)];
                          });
                        }else{
                          setState(() {
                            selection.selections.removeLast();
                            selection.prices.removeLast();
                            selection.selections.insert(0, optionName);
                            selection.prices.insert(0,
                                option.price[option.options.indexOf(
                                    optionName)]);
                            price +=
                            option.price[option.options.indexOf(optionName)];
                          });
                        }
                      }
                      print(selection);
                    },
                    child: Container(
                      height: 30,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.centerLeft,
                        children: <Widget>[
                          option.maxSelection == 1 ? Flex(
                            direction: Axis.horizontal,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  selection.selections.contains(optionName)?
                                  Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  color: selection.selections.contains(optionName)?
                                  Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ],
                          ):Flex(
                            direction: Axis.horizontal,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  selection.selections.contains(optionName)?
                                  Icons.check_box : Icons.check_box_outline_blank,
                                  color: selection.selections.contains(optionName)?
                                  Theme.of(context).primaryColor : Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$optionName ${option.price[option.options.indexOf(optionName)]<=0? '': '(+\$${option.price[option.options.indexOf(optionName)].toStringAsFixed(2)})'}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.subhead.apply(color: selection.selections.contains(optionName)? Theme.of(context).primaryColorDark: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    )
                    );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityAdjustor(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FlatButton(
          child: Icon(Icons.remove),
          onPressed: (){
            if(quantity > 1)
              setState(() {
                quantity--;
              });
          },
        ),
        Text(
          '$quantity ${foodItem.name}${quantity>1? 's':''}',
          style: Theme.of(context).textTheme.subtitle.apply(fontWeightDelta: 1, fontSizeFactor: 1.2),
        ),
        FlatButton(
          child: Icon(Icons.add),
          onPressed: (){
            setState(() {
              quantity++;
            });
          },
        ),

      ],
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
          color: Theme.of(context).primaryColorLight,
          padding: EdgeInsets.all(8.0),
          onPressed: myRating<=0?null:(){
            rateAndReview();
          },
          child: Text(
            '${myRating<=0?'Tap Stars to Rate':'${reviewController.text==''?'Rate':'Rate and Review'}'}',
            style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }
}