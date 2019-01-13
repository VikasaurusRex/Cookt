import 'package:flutter/material.dart';

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
                child: Text('Order Time'),
              ),
              Padding(padding: EdgeInsets.all(2.0),),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text('Dine In'),
              ),
              Padding(padding: EdgeInsets.all(2.0),),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text('Quantity'),
              ),
              Padding(padding: EdgeInsets.all(2.0),),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: FlatButton(
                  color: Theme.of(context).buttonColor,
                  onPressed: orderDineInCarryOut,
                  child: Text('Order for Carry Out / Dine In'),
                ),
              ),
              Padding(padding: EdgeInsets.all(2.0),),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: FlatButton(
                  color: Theme.of(context).buttonColor,
                  onPressed: orderDelivery,
                  child: Text('Order for Delivery'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void orderDineInCarryOut(){
    print('Ordering');
  }

  void orderDelivery(){
    print('Ordering for Delivery');
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