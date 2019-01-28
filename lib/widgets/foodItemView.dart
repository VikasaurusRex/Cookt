import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:cookt/models/foodItem.dart';
import 'orderButton.dart';

class FoodItemView extends StatefulWidget {
  final DocumentReference reference;

  FoodItemView({@required this.reference});

  @override
  _FoodItemViewState createState() => _FoodItemViewState();
}

class _FoodItemViewState extends State<FoodItemView> {
  // One TextEditingController for each form input:
  bool hasOrdered = false;
  FoodItem foodItem = FoodItem.newItem();
  List<Widget> images = [];
  List<Review> reviews = [];
  TextEditingController reviewController = TextEditingController();
  int myRating = 0;

  GoogleMapController mapController;

  OrderButton orderButton;

  LatLng myCoords = null;
  LatLng cookCoords = null;

  @override
  Widget build(BuildContext context) {
    loadReviews();
    checkIfOrdered();
    loadLocation();
    return StreamBuilder<DocumentSnapshot>(
      stream: widget.reference.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: Text('Loading...', style: Theme.of(context).textTheme.subhead, ));
        foodItem = FoodItem.fromSnapshot(snapshot.data);
        loadCookLocation(foodItem);
        setState(() {
          orderButton = OrderButton(foodItem: foodItem,);
        });
        return _buildFoodItem();
      },
    );
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
  }

  void updateMap(){
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

  void loadReviews() async {
    await for (QuerySnapshot snapshots in widget.reference
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

  void checkIfOrdered() async {
    await for (QuerySnapshot snapshots in Firestore.instance
        .collection("orders")
        .where('customerID', isEqualTo: 'usercustomer')
        .where('foodId', isEqualTo: '${widget.reference.documentID}')
        .snapshots().asBroadcastStream()) {
      for (DocumentSnapshot snapshot in snapshots.documents) {
        if(snapshot.exists){
          hasOrdered = true;
        }
      }
    }
  }

  Widget _buildFoodItem(){
    return Scaffold(
      appBar: AppBar(
        title: Text("${foodItem.name}"),
//        leading: IconButton(
//          icon: Icon(Icons.chevron_left),
//          iconSize: 40.0,
//          onPressed: _showMyFoodItems,
//        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0)),
            _imagesScroll(),
            Padding(padding: EdgeInsets.all(8.0),),
            _description(),
            Padding(padding: EdgeInsets.all(8.0),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _rating(),
                _price(),
              ],
            ),
            Padding(padding: EdgeInsets.all(8.0),),
            _dineInAvailability(),
            Padding(padding: EdgeInsets.all(8.0),),
            _map(),
            Padding(padding: EdgeInsets.all(8.0),),
            _categories(),
            Padding(padding: EdgeInsets.all(8.0),),
            _rateAndReview(),
            Padding(padding: EdgeInsets.all(8.0),),
            _otherReviews(),
            Padding(padding: EdgeInsets.all(50.0),),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: orderButton,
    );
  }

//  Future _showMyFoodItems() async {
//    // push a new route like you did in the last section
//    Navigator.of(context).push(
//      MaterialPageRoute(
//        builder: (BuildContext context) {
//          return CurrentOrders();
//        },
//      ),
//    );
//  }

  Widget _imagesScroll() {
    final Size screenSize = MediaQuery.of(context).size;
    for(int i = 0; i < foodItem.numImages && images.length<foodItem.numImages; i++){
      images.add(foodItem.foodImage(context,i));
    }
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
      child: Text('Price: \$${foodItem.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.subhead,),
    );
  }

  Widget _dineInAvailability(){
    return Column(
      children: <Widget>[
        Text('${foodItem.dineInAvailable?'Dine In or Carry Out':'Only Available for Carry Out'}', style: Theme.of(context).textTheme.subhead,),
      ],
    );
  }

  Widget _map(){
    return Container(
      height: 400.0,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        options: GoogleMapOptions(
          mapType: MapType.hybrid,
          myLocationEnabled: true,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: false,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }

  Widget _categories(){
    bool leftCol = false;
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
    
    if(left.length%2==1)
      left.add(Container(height: 50.0,));

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
          onPressed: myRating<=0?null:(){
            rateAndReview();
          },
          child: Text('${myRating<=0?'Tap Stars to Rate':'${reviewController.text==''?'Rate':'Rate and Review'}'}'),
        ),
      ],
    );
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
    Review.createReview(reviewController.text, myRating, foodItem);
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

  Widget _otherReviews(){
    List<Widget> reviewCards = [];

    for(Review review in reviews){
      if(review.review == '')
        continue;
      reviewCards.add(
        Builder(builder: (builder){
          return Padding(
            padding: EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(5.0)
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        review.reviewerName(context),
                        Padding(padding: EdgeInsets.all(4.0),),
                        Row(
                          children: <Widget>[
                            Text('${review.rating}', style: Theme.of(context).textTheme.subhead,),
                            Padding(padding: EdgeInsets.all(2.0),),
                            Icon(Icons.star, size: 15.0,)
                          ],
                        )
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(4.0),),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('${review.review}', style: Theme.of(context).textTheme.subhead),
                      )
                    ),
                  ],
                ),
              )
            ),
          );
        })
      );
    }

    if(reviewCards.length == 0){
      reviewCards.add(
        Builder(builder: (builder){
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              height: 100.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Center(
                child: Text('No Reviews Yet.', style: Theme.of(context).textTheme.subhead,)
              )
            ),
          );
        })
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Reviews', style: Theme.of(context).textTheme.headline,),
        Padding(padding: EdgeInsets.all(4.0),),
        Container(
          height: 250,
          child: ListView(
            children: reviewCards,
          ),
        ),
      ],
    );
  }
}