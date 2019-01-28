import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:cookt/models/orderData.dart';
import 'package:cookt/models/foodItem.dart';

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
  Animation<Color> _buttonColor;
  AnimationController _animationController;
  Animation<double> _translateButton;
  Animation<double> _animateIcon;

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

  void deliveryAllowed(){

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