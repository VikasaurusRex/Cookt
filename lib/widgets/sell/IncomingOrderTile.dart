import 'package:flutter/material.dart';

import 'package:cookt/models/orders/Order.dart';
import 'package:cookt/models/orders/Item.dart';
import 'package:cookt/models/DatabaseIntegrator.dart';

import 'IncomingItemTile.dart';

class IncomingOrderTile extends StatefulWidget {
  final Order order;

  // PENDING OPTIONS
  final Function(Order) acceptFinishOrder;

  // REQUESTED, ACCEPTED OPTIONS
  final Function(Order) cancelOrder;

  final Key key;

  IncomingOrderTile(this.order, this.acceptFinishOrder,this.cancelOrder, {@required this.key});

  @override
  State<StatefulWidget> createState() =>_IncomingOrderTileState(order);
}

class _IncomingOrderTileState extends State<IncomingOrderTile> {
  final Order order;
  List<Item> items = List();

  String _totalPrice = "";

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

  _IncomingOrderTileState(this.order){
    order.reference.collection('items').snapshots().forEach((querySnapshot){
      querySnapshot.documents.forEach((snapshot){
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
    return Container(
      color: order.status != Status.accepted && order.active?Color(0xFFDDFFDD):Theme.of(context).canvasColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.0, 8, 8, 8),
        child: Container(
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('${order.active? 'Ready by':order.status == Status.finished?'Completed at':'Cancelled by ${order.lastTouchedID == 'usercook'? 'you at': 'customer at'}'} ${DatabaseIntegrator.simplifiedDate(order.active?order.pickupTime:order.lastTouchedTime)}'),
              ),
              Container(
                color: Colors.grey,
                height: 1.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: items.map((item) => IncomingItemTile(item, accepted: order.status == Status.accepted, key: Key(item.toString()),)).toList(),
                ),
              ),
              Container(
                color: Colors.grey,
                height: 1.0,
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Total: \$$_totalPrice', style: Theme.of(context).textTheme.title,),
              ),
              _orderOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderOptions(){
    return order.active?
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: RaisedButton(
            color: order.status == Status.accepted?Color(0xFFCCFFCC):Color(0xFF99FF99),
            onPressed: (){
              if(order.status == Status.requested){
                widget.acceptFinishOrder(order);
                return;
              }
              bool allCompleted = true;
              items.forEach((item){
                if(!item.prepared)
                  allCompleted = false;
              });
              if(allCompleted)
                widget.acceptFinishOrder(order);
              else
                _notPreparedError();
            },
            child: Text(order.status == Status.accepted?'Finish':'Accept', style: TextStyle(color: Colors.green),),
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 4.0),),
        Expanded(
          child: RaisedButton(
            color: Color(0xFFFFCCCC),
            onPressed: () {
              widget.cancelOrder(order);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.red),),
          ),
        )
      ],
    )
        :
    Container(
      height: 3,
      color: Colors.grey,
    );
  }

  Future<void> _notPreparedError() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Prepare all items before finishing order.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please tap each item in the order to confirm that you have completed preparing it.'),
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