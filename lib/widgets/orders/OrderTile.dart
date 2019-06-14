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

  double _taxRate = 0;
  double _cooktRate = 0;
  double _deliveryQuote = 0;
  String _kitchenName = "";

  bool shouldLoadLocation = true;
  LatLng myCoords = null;
  LatLng cookCoords = null;

  void loadData(){
    DatabaseIntegrator.kitchenName(order.cookID).then((val) => setState(() {
      _kitchenName = val;
    }));
  }

  void calculatePrice(){
    double price = 0;

    items.forEach((item){
      price += item.price*item.quantity;
    });
    setState(() {
      order.subtotalPrice = price;
      order.cooktPrice = (price*_cooktRate);
      order.taxPrice = (price*_taxRate);
    });

    price += order.cooktPrice;
    price += order.taxPrice;
    if(order.orderType == OrderType.postmates){
      order.deliveryPrice = _deliveryQuote;
      price+=order.deliveryPrice;
    }else{
      order.deliveryPrice = 0;
    }
    order.totalPrice = price;
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
      cookCoords = LatLng(cook.loc.latitude, cook.loc.longitude);
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

    updateTax(zip: cookAddress.postalCode);

    http.post(url,headers: headers,body: body).then((response){
      Map<String, dynamic> quote = jsonDecode(response.body);
      if(quote['kind'] == 'error'){
        return;
      }else if(quote['kind'] == 'delivery_quote'){
        setState(() {
          _deliveryQuote = quote['fee'].toDouble()/100;
          availableOrderTypeLabels.add('Delivery (+\$${_deliveryQuote.toStringAsFixed(2)})');
          availableOrderTypes.add(OrderType.postmates);
        });
      }
    });
  }

  void updateTax({String zip}){
    String url = 'https://api.taxjar.com/v2/rates/$zip';

    Map<String, String> headers = Map();
    headers['Authorization'] = 'Bearer 0fa76332396eaec7be5f9c63c143fc5e';
    headers['Content-Type'] = 'application/json';

    http.get(url,headers: headers).then((response){
      Map<String, dynamic> quote = jsonDecode(response.body);
      if(quote['rate'] == null){
        return;
      }else{
        _taxRate = double.parse(quote['rate']['combined_rate']);
        order.taxZip = zip;
        calculatePrice();
      }
    });
  }

  void refresh(){
    DatabaseIntegrator.cooktTake().then((val) => setState(() {
      _cooktRate = val;
      calculatePrice();
    }));

    DatabaseIntegrator.dineInAvailable(order.cookID).then((val) => setState(() {
      if(val){
        availableOrderTypeLabels.add('Dine In');
        availableOrderTypes.add(OrderType.dineIn);
      }
    }));
  }

  _OrderTileState(this.order){
    loadData();

    if(order.status == Status.pending) {
      order.refresh();
      refresh();
      loadLocation();
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
      _time[Status.accepted] = 'Ready for pickup at ${DatabaseIntegrator.simplifiedDate(order.pickupTime.toLocal())}';
    }else if(order.orderType == OrderType.dineIn){
      _time[Status.accepted] = 'Reservation at ${DatabaseIntegrator.simplifiedDate(order.pickupTime.toLocal())}';
    }else{
      _time[Status.accepted] = 'Order will be delivered at ${DatabaseIntegrator.simplifiedDate(order.pickupTime.toLocal())}';
    }
    _time['CANCELLED'] = 'Order was cancelled at ${DatabaseIntegrator.simplifiedDate(order.lastTouchedTime.toLocal())}';
    _time[Status.finished] = '${DatabaseIntegrator.simplifiedDate(order.lastTouchedTime.toLocal())}';

    order.reference.collection('items').snapshots().forEach((querySnapshot){
      querySnapshot.documents.forEach((snapshot){
        //print('  Found the item ${snapshot.documentID}: ${snapshot.data}');
        if(!items.contains(Item.fromSnapshot(snapshot))){
          setState(() {
            items.add(Item.fromSnapshot(snapshot));
          });
          if(order.status == Status.pending)
            calculatePrice();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //print('  Number of items in order: ${items.length}');
    return Container(
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
            _orderOptions(),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
              child: Container(
                color: Colors.grey,
                height: 1.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                children: items.map((item) => ItemTile(item, deleteItem, order.status == Status.pending && order.active == true, key: Key(item.toString()), calculatePrice: calculatePrice,)).toList(),
              ),
            ),
            Container(
              color: Colors.grey,
              height: 1.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: _priceBreakdown(),
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
//                child: BackdropFilter(
//                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('$_kitchenName', style: Theme.of(context).textTheme.headline.apply(fontWeightDelta: 2),),
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

  Widget _orderOptions(){
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(),
        ),
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
            decoration: BoxDecoration(
              color: order.status == Status.pending && order.active == true?Color(0xFFCCFFCC):Colors.transparent,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Padding(padding: EdgeInsets.all(4),
              child: Text(availableOrderTypeLabels[selectedOrderTypeIndex], style: Theme.of(context).textTheme.subtitle),
            ),
          )
        ),
        order.status == Status.pending && order.active == true?Icon(
          Icons.chevron_left,
        ):Container(),
      ],
    );
  }

  Widget _priceBreakdown(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        //TODO: Implement proper pricing for cookt fee, total fee, and tax
        Text('Subtotal: \$${order.subtotalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.subhead,textAlign: TextAlign.right,),
        Text('Tax: \$${order.taxPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.subhead,textAlign: TextAlign.right,),
        Text('Cookt Fee: \$${order.cooktPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.subhead,textAlign: TextAlign.right,),
        Text('Delivery: \$${order.deliveryPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.subhead,textAlign: TextAlign.right,),
        Padding(padding: EdgeInsets.symmetric(vertical: 2.0),),
        Container(
          height: 1,
          color: Colors.grey,
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 2.0),),
        Text('Total: \$${order.totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.subhead.apply(fontSizeFactor: 1.2, fontWeightDelta: 2),textAlign: TextAlign.right,),
      ],
    );
  }

  Widget _nextLineOptions(){
    if(order.status != Status.finished && order.active == false) {
      return RaisedButton(
        color: Color(0xFFCCFFCC),
        onPressed: (){
          widget.reorder(order);
        },
        child: Text(
          'Reorder',
          style: Theme.of(context).textTheme.title.apply(color: Colors.green),
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
                    color: Color(0xFFEFEFEF),
                    onPressed: (){
                      changeOrderTime(increase: false);
                    },
                    child: Icon(Icons.chevron_left, size: 30,),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${order.pickupTime.day == DateTime.now().day? 'Today':DatabaseIntegrator.dayOfTheWeek(order.pickupTime.weekday)} ${order.pickupTime.hour>12?order.pickupTime.hour-12:order.pickupTime.hour==0?12:order.pickupTime.hour}:${order.pickupTime.minute==0?'00':'30'} ${order.pickupTime.hour>=12?'PM':'AM'}',
                      style: Theme.of(context).textTheme.title,),
                  ),
                ),
                SizedBox(
                  width: 50,
                  height: 30,
                  child: FlatButton(
                    color: Color(0xFFEFEFEF),
                    onPressed: (){
                      changeOrderTime(increase: true);
                    },
                    child: Icon(Icons.chevron_right, size: 30,),
                  ),
                ),
                Padding(padding: EdgeInsets.all(5),),
              ],
            ),
            RaisedButton(
              color: Color(0xFFCCFFCC),
              onPressed: (){
                if(_taxRate > 0 && _cooktRate > 0 && ((order.orderType == OrderType.postmates && order.deliveryPrice > 0) || order.orderType != OrderType.postmates))
                  widget.placeOrder(order);
                else
                  _networkErrorDialog();
              },
              child: Text(
                'Place Order',
                style: Theme.of(context).textTheme.title.apply(color: Colors.green),
              ),
            )
          ],
        );
        break;
      case Status.requested:
        return RaisedButton(
            color: Color(0xFFFFCCCC),
          onPressed: (){
            widget.cancelOrder(order);
          },
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.title.apply(color: Colors.red),
          )
        );
        break;
      case Status.accepted:
        return RaisedButton(
            color: Color(0xFFFFCCCC),
            onPressed: (){
              widget.cancelOrder(order);
            },
            child: Text(
              'Cancel (Possible Fee)',
              style: Theme.of(context).textTheme.title.apply(color: Colors.red),
            )
        );
        break;
      case Status.finished:
        return RaisedButton(
            color: Color(0xFFCCFFCC),
            onPressed: (){
              widget.reorder(order);
            },
            child: Text(
              'Reorder',
              style: Theme.of(context).textTheme.title.apply(color: Colors.green),
            )
        );
        break;
      default:
        return Container();
        break;
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
        print('no items');
        order.reference.delete();
      }
    });
  }

  Future<void> _networkErrorDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error Loading Taxes and Fees. Are you connected to the internet?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please connect to the network or wait for the fields to load.'),
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