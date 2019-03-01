import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocoder/geocoder.dart';

import 'package:cookt/models/OrderData.dart';
import 'package:cookt/models/FoodItem.dart';

class OrderButton extends StatefulWidget {
  final FoodItem foodItem;

  OrderButton({@required this.foodItem});

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton>
    with SingleTickerProviderStateMixin {

  OrderData order;
  bool isOpened = false;
  double deliveryPrice = -1;

  bool shouldLoadLocation = true;
  Animation<Color> _buttonColor;
  AnimationController _animationController;
  Animation<double> _translateButton;
  Animation<double> _animateIcon;

  LatLng myCoords = null;
  LatLng cookCoords = null;

  @override
  initState() {

    order = OrderData.newItem(widget.foodItem);

    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });

    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _buttonColor = ColorTween(
      begin: Colors.black,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));

    _translateButton = Tween<double>(
      begin: 400,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: Curves.easeOut,
      ),
    ));

    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  void loadLocation() async{
    if(!shouldLoadLocation){
      return;
    }
    var location = new Location();
    try {
      Map<String, double> currentLocation = await location.getLocation();
      if(myCoords==null || (myCoords.latitude-currentLocation["latitude"]).abs()>=0.01 || (myCoords.longitude-currentLocation["longitude"]).abs()>=0.01)
        setState(() {
          myCoords = LatLng(currentLocation["latitude"], currentLocation["longitude"]);
        });
      updateDelivery();
    } on Exception {}
    FirebaseDatabase.instance.reference().child(widget.foodItem.uid).child('userinfo').onValue.listen((onValue){
      var data = onValue.snapshot.value;
      cookCoords = LatLng(data['lat'], data['long']);
      updateDelivery();
    });
  }

  void updateDelivery() async {
    print('updating delivery...');
    if(myCoords == null || cookCoords == null){
      print('nvm returning');
      return;
    }
    shouldLoadLocation = false;
    String url = 'https://api.postmates.com/v1/customers/cus_Kf3bMZuhfEUbQV/delivery_quotes';
    Map<String, String> headers = Map();
    headers['Authorization'] = 'Basic ZWZmY2RhOTItZWNjMy00ZGI2LWI5NTQtZjhkOTE0ZTA5NGQ5Og==';
    headers['Content-Type'] = 'application/x-www-form-urlencoded';

    List<Address> myAddresses = await Geocoder.local.findAddressesFromCoordinates(Coordinates(myCoords.latitude, myCoords.longitude));
    Address myAddress = myAddresses.first;

    List<Address> cookAddresses = await Geocoder.local.findAddressesFromCoordinates(Coordinates(cookCoords.latitude, cookCoords.longitude));
    Address cookAddress = cookAddresses.first;

    Map<String, String> body = Map();

    print('${myAddress.addressLine}');
    print('${cookAddress.addressLine}');

    body['pickup_address'] = '${cookAddress.addressLine}';
    body['dropoff_address'] = '${myAddress.addressLine}';

    http.post(url,headers: headers,body: body).then((response){
      print('call responded...');
      Map<String, dynamic> quote = jsonDecode(response.body);
      if(quote['kind'] == 'error'){
        return;
      }else if(quote['kind'] == 'delivery_quote'){
        print(quote['fee']);print(quote['fee']);
        setState(() {
          deliveryPrice = quote['fee'].toDouble();
        });
      }
    });
  }

  Widget menu() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.black),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(5),),
                    SizedBox(
                      width: 50,
                      height: 30,
                      child: FlatButton(
                        onPressed: (){
                          changeOrderTime(increase: false);
                        },
                        child: Icon(Icons.chevron_left),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text('${order.pickupTime.day == DateTime.now().day? 'Today':dayOfTheWeek(order.pickupTime.weekday)} ${order.pickupTime.hour>12?order.pickupTime.hour-12:order.pickupTime.hour==0?12:order.pickupTime.hour}:${order.pickupTime.minute==0?'00':'30'} ${order.pickupTime.hour>=12?'PM':'AM'}'),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 30,
                      child: FlatButton(
                        onPressed: (){
                          changeOrderTime(increase: true);
                        },
                        child: Icon(Icons.chevron_right),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(5),),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(2.0),),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(5),),
                    Expanded(
                      child: Text('Dine In', style: Theme.of(context).textTheme.subhead,),
                    ),
                    Switch.adaptive(
                      value: order.dineIn && widget.foodItem.dineInAvailable,
                      onChanged: (bool newState) {
                        setState(() {
                          order.dineIn = newState && widget.foodItem.dineInAvailable;
                          if(!widget.foodItem.dineInAvailable){
                            _presentDialog();
                          }
                        });
                      },
                    ),
                    Padding(padding: EdgeInsets.all(5),),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(2.0),),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(5),),
                    SizedBox(
                      width: 50,
                      height: 30,
                      child: FlatButton(
                        onPressed: (){
                          if(order.quantity<=1)
                            return;
                          setState(() {
                            order.quantity--;
                          });
                        },
                        child: Icon(Icons.remove),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text('${order.quantity} ${widget.foodItem.name}${order.quantity>1?'s':''}'),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 30,
                      child: FlatButton(
                        onPressed: (){
                          setState(() {
                            order.quantity++;
                          });
                        },
                        child: Icon(Icons.add),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(5),),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(2.0),),
              Container(
                height: 50,
                child: FlatButton(
                  color: Theme.of(context).buttonColor,
                  onPressed: orderDineInCarryOut,
                  child: Text('${order.dineIn?'Request Reservation':'Order for Carry Out'}'),
                ),
              ),
              Padding(padding: EdgeInsets.all(2.0),),
              Container(
                height: 50,
                child: FlatButton(
                  color: order.dineIn?Colors.grey:Colors.black,
                  onPressed: deliveryPrice<0?null:order.dineIn?null:orderDelivery,
                  splashColor: Colors.grey,
                  child: Text('Order for Delivery (+${(deliveryPrice/100.0).toStringAsFixed(2)})', style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String dayOfTheWeek(int weekday){
    switch(weekday){
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'ERROR';
    }
  }

  void changeOrderTime({@required bool increase}){
    if((order.pickupTime.compareTo(DateTime.now().add(Duration(minutes: 45)))<0 && !increase) || (order.pickupTime.compareTo(DateTime.now().add(Duration(minutes: 300))) > 0 && increase))
      return;
    if(!increase){
      setState(() {
        order.pickupTime = order.pickupTime.add(Duration(minutes: -30));
      });
      return;
    }
    setState(() {
      order.pickupTime = order.pickupTime.add(Duration(minutes: 30));
    });
  }

  Future<void> _presentDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dine in not offered'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This cook has disabled the option for dine in. Sorry for the inconvenience.'),
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

  void orderDineInCarryOut(){
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to order'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your order will be placed now.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                animate();
                order.createListing();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void orderDelivery(){
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure you want to order'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your order will be placed now.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                animate();
                order.postmatesOrder = true;
                order.createListing();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget floatingButton() {
    return Container(
      height: 90,
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 50,
            width: 100,
            child: FloatingActionButton(
              backgroundColor: _buttonColor.value,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              onPressed: animate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _animateIcon,
                  ),
                  Padding(padding: EdgeInsets.all(4.0),),
                  Text(isOpened?'Close':'Order')
                ],
              )
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    loadLocation();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: menu(),
        ),
        floatingButton(),
      ],
    );
  }
}