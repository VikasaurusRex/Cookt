import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:location/location.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/orders/Order.dart';
import 'package:cookt/models/orders/Item.dart';
import 'package:cookt/models/DatabaseIntegrator.dart';
import 'package:cookt/models/User.dart';
import 'ItemTile.dart';

class OrderTile extends StatefulWidget {
  final Order order;

  // PENDING OPTIONS
  final Function(Order) deleteOrder;
  final Function(Order) placeOrder;

  // REQUESTED, ACCEPTED OPTIONS
  final Function(Order) cancelOrder;

  // FINISHED / CANCELLED OPTIONS
  final Function(Order) reorder;

  Key key;

  OrderTile(this.order, this.deleteOrder, this.placeOrder, this.cancelOrder, this.reorder, {@required this.key});

  @override
  State<StatefulWidget> createState() =>_OrderTileState(order);
}

class _OrderTileState extends State<OrderTile> {
  final Order order;
  List<Item> items = List();

  Map<String, String> _status =  Map();
  Map<String, IconData> _statusIcon = Map();
  Map<String, String> _time =  Map();

  List<String> availableOrderTypeLabels = ['Pick Up'];
  List<String> availableOrderTypes = [OrderType.pickup];
  int selectedOrderTypeIndex = 0;

  String _totalPrice = "";
  String _kitchenName = "";

  bool shouldLoadLocation = true;
  LatLng myCoords = null;
  LatLng cookCoords = null;

  void loadData(){
    
    DatabaseIntegrator.dineInAvailable(order.cookID).then((val) => setState(() {
      if(val){
        availableOrderTypeLabels.add('Dine In');
        availableOrderTypes.add(OrderType.dineIn);
      }
    }));

    DatabaseIntegrator.kitchenName(order.cookID).then((val) => setState(() {
      _kitchenName = val;
    }));
  }

  String simplifiedDate(DateTime date){
    String month;

    switch (date.month){
      case 1: { month = 'Jan'; }
      break;
      case 2: { month = 'Feb'; }
      break;
      case 3: { month = 'Mar'; }
      break;
      case 4: { month = 'Apr'; }
      break;
      case 5: { month = 'May'; }
      break;
      case 6: { month = 'June'; }
      break;
      case 7: { month = 'July'; }
      break;
      case 8: { month = 'Aug'; }
      break;
      case 9: { month = 'Sep'; }
      break;
      case 10: { month = 'Oct'; }
      break;
      case 11: { month = 'Nov'; }
      break;
      case 12: { month = 'Dec'; }
      break;
      default: { month = '---'; }
      break;
    }

    return '${month} ${date.day}, ${date.year} at ${date.hour%12==0?'12':date.hour%12}:${date.minute} ${date.hour>11?'PM':'AM'}';
  }

  void calculatePrice(){
    double price = 0;
    items.forEach((item){
      price += item.price;
    });
    if(order.orderType == OrderType.postmates){
      price+=order.deliveryPrice;
    }
    setState(() {
      _totalPrice = '${price.toStringAsFixed(2)}';
    });
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
    Firestore.instance.collection('users').document(order.cookID).get().then((snapshot){
      User cook = User.fromSnapshot(snapshot);
      cookCoords = LatLng(cook.lat, cook.long);
      updateDelivery();
    });
  }

  void updateDelivery() async {
    if(myCoords == null || cookCoords == null){
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
      Map<String, dynamic> quote = jsonDecode(response.body);
      if(quote['kind'] == 'error'){
        return;
      }else if(quote['kind'] == 'delivery_quote'){
        setState(() {
          order.setDeliveryPrice(quote['fee'].toDouble()/100);
          availableOrderTypeLabels.add('Delivery (+\$${order.deliveryPrice.toStringAsFixed(2)})');
          availableOrderTypes.add(OrderType.postmates);
        });
      }
    });
  }

  _OrderTileState(this.order){
    loadData();
    loadLocation();

    if(order.status == Status.pending) {
      order.refresh();
    }

    _status[Status.pending] = 'Order is Pending';
    _status[Status.requested] = 'Order has been Requested';
    _status[Status.accepted] = 'Order has been Accepted';
    _status['CANCELLED'] = 'Order has been Cancelled';
    _status[Status.finished] = 'Order has been Completed';

    _statusIcon[Status.pending] = Icons.shopping_basket;
    _statusIcon[Status.requested] = Icons.present_to_all;
    _statusIcon[Status.accepted] = Icons.store;
    _statusIcon['CANCELLED'] = Icons.cancel;
    _statusIcon[Status.finished] = Icons.done;

    _time[Status.pending] = 'Select a time below to order';
    _time[Status.requested] = 'Your order has been sent for confirmation.';
    if(order.orderType == OrderType.pickup){
      _time[Status.accepted] = 'Ready for pickup at ${simplifiedDate(order.pickupTime.toLocal())}';
    }else if(order.orderType == OrderType.dineIn){
      _time[Status.accepted] = 'Reservation at ${simplifiedDate(order.pickupTime.toLocal())}';
    }else{
      _time[Status.accepted] = 'Order will be delivered at ${simplifiedDate(order.pickupTime.toLocal())}';
    }
    _time['CANCELLED'] = 'Order was cancelled at ${simplifiedDate(order.lastTouchedTime.toLocal())}';
    _time[Status.finished] = '${simplifiedDate(order.lastTouchedTime.toLocal())}';

    order.reference.collection('items').snapshots().forEach((querySnapshot){
      querySnapshot.documents.forEach((snapshot){
        //print('  Found the item ${snapshot.documentID}: ${snapshot.data}');
        if(!items.contains(Item.fromSnapshot(snapshot))){
          setState(() {
            items.add(Item.fromSnapshot(snapshot));
          });
          calculatePrice();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //print('  Number of items in order: ${items.length}');
    return Container(
        //color: Colors.black12,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.0, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _kitchenImage(),
            _statusLabel(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text((order.status != Status.finished && order.active == false)? _time['CANCELLED'] :_time[order.status], style: Theme.of(context).textTheme.subhead.apply(fontSizeFactor: 0.75),),
            ),
            Container(
              color: Colors.grey,
              height: 1.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                children: items.map((item) => ItemTile(item, deleteItem, key: Key(item.toString()),)).toList(),
              ),
            ),
            Container(
              color: Colors.grey,
              height: 1.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Total: \$$_totalPrice', style: Theme.of(context).textTheme.title,),
                  _inLineOptions(),
                ],
              )
            ),
            _nextLineOptions(),
            Container(
              color: Colors.grey,
              height: 3.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _kitchenImage(){
    return Container(
        height: 150,
        child: Stack(
            alignment: AlignmentDirectional.center,
            fit: StackFit.expand,
            children: <Widget>[
              DatabaseIntegrator.storefrontImage(order.cookID),
              Center(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('$_kitchenName', style: Theme.of(context).textTheme.headline.apply(fontWeightDelta: 2),),
                    ),
                  ),
                ),
              ),
            ]
        )
    );
  }

  Widget _statusLabel(){
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
        child: Row(
          children: <Widget>[
            Icon((order.status != Status.finished && order.active == false)? _statusIcon['CANCELLED'] : _statusIcon[order.status]),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Text((order.status != Status.finished && order.active == false)? _status['CANCELLED'] :_status[order.status], style: Theme.of(context).textTheme.subhead,),
              ),
            ),
            order.status == Status.pending && order.active == true?InkWell(
              child: Icon(Icons.delete),
              onTap: (){
                widget.deleteOrder(order);
              },
            )
                :
            Container(),
          ],
        )
    );
  }

  Widget _inLineOptions(){
    return Row(
      children: <Widget>[
        Text('For: ', style: Theme.of(context).textTheme.subtitle,),
        order.status == Status.pending && order.active == true?Icon(
          Icons.chevron_right,
          //size: 10,
        ):Container(),
        InkWell(
          onTap: order.status == Status.pending && order.active == true?(){
            setState(() {
              selectedOrderTypeIndex = (selectedOrderTypeIndex + 1)%availableOrderTypes.length;
              order.orderType = availableOrderTypes[selectedOrderTypeIndex];
            });
            calculatePrice();
          }:null,
          child: Container(
            decoration: order.status == Status.pending && order.active == true?BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(5.0),
            ):null,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Text(availableOrderTypeLabels[selectedOrderTypeIndex], style: Theme.of(context).textTheme.subtitle),
            ),
          ),
        ),
        order.status == Status.pending && order.active == true?Icon(
          Icons.chevron_left,
        ):Container(),
      ],
    );
  }

  Widget _nextLineOptions(){
    if(order.status != Status.finished && order.active == false) {
      return FlatButton(
          color: Colors.black12,
          onPressed: (){
            widget.reorder(order);
          },
          child: Text(
            'Reorder',
            style: Theme.of(context).textTheme.title,
          )
      );
    }

    switch (order.status){
      case Status.pending:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
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
                    child: Icon(Icons.chevron_left, size: 30,),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${order.pickupTime.day == DateTime.now().day? 'Today':dayOfTheWeek(order.pickupTime.weekday)} ${order.pickupTime.hour>12?order.pickupTime.hour-12:order.pickupTime.hour==0?12:order.pickupTime.hour}:${order.pickupTime.minute==0?'00':'30'} ${order.pickupTime.hour>=12?'PM':'AM'}',
                      style: Theme.of(context).textTheme.title,),
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 30,
                  child: FlatButton(
                    onPressed: (){
                      changeOrderTime(increase: true);
                    },
                    child: Icon(Icons.chevron_right, size: 30,),
                  ),
                ),
                Padding(padding: EdgeInsets.all(5),),
              ],
            ),
            FlatButton(
              color: Colors.black12,
              onPressed: (){
                widget.placeOrder(order);
              },
              child: Text(
                'Place Order',
                style: Theme.of(context).textTheme.title,
              ),
            )
          ],
        );
        break;
      case Status.requested:
        return FlatButton(
          color: Colors.black12,
          onPressed: (){
            widget.cancelOrder(order);
          },
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.title,
          )
        );
        break;
      case Status.accepted:
        return FlatButton(
            color: Colors.black12,
            onPressed: (){
              widget.cancelOrder(order);
            },
            child: Text(
              'Cancel (Possible Fee)',
              style: Theme.of(context).textTheme.title,
            )
        );
        break;
      case Status.finished:
        return FlatButton(
            color: Colors.black12,
            onPressed: (){
              widget.reorder(order);
            },
            child: Text(
              'Reorder',
              style: Theme.of(context).textTheme.title,
            )
        );
        break;
      default:
        return Container();
        break;
    }
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

  void deleteItem(Item item){
    item.deleteItem();
    setState(() {
      items.remove(item);
      calculatePrice();
      if(items.length <= 0){
        widget.deleteOrder(order);
      }
    });
  }
}