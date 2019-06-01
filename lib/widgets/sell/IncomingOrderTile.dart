import 'package:flutter/material.dart';

import 'package:cookt/models/orders/Order.dart';
import 'package:cookt/models/orders/Item.dart';
import 'package:cookt/models/DatabaseIntegrator.dart';
import 'package:cookt/widgets/orders/ItemTile.dart';

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
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 8, 8, 8),
      child: Container(
      //color: Colors.black12,

        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('${order.active? 'Ready by':'Cancelled by ${order.lastTouchedID == 'usercook'? 'you at': 'customer at'}'} ${DatabaseIntegrator.simplifiedDate(order.active?order.pickupTime:order.lastTouchedTime)}'),
            ),
            Container(
              color: Colors.grey,
              height: 1.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                children: items.map((item) => ItemTile(item, null, key: Key(item.toString()),)).toList(),
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
    );
  }

  Widget _orderOptions(){
    return order.active?
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: RaisedButton(
            color: Color(0xFFCCFFCC),
            onPressed: (){
              widget.acceptFinishOrder(order);
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
}