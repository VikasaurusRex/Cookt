import 'package:flutter/material.dart';

import 'package:cookt/models/orders/Item.dart';
import 'package:cookt/models/DatabaseIntegrator.dart';
import 'package:cookt/models/orders/Selection.dart';

import 'package:cookt/widgets/orders/ItemTile.dart';

class IncomingItemTile extends StatefulWidget {
  final Item item;
  final bool accepted;

  Key key;

  IncomingItemTile(this.item, {@required this.key, this.accepted});

  @override
  State<StatefulWidget> createState() =>_IncomingItemTileState(item);
}

class _IncomingItemTileState extends State<IncomingItemTile> {
  final Item item;
  String _itemName = '';
  List<Selection> selections = List();

  void loadData(){
    DatabaseIntegrator.foodName(item.foodID).then((val){
      setState(() {
        _itemName = val;
      });
    });
  }

  _IncomingItemTileState(this.item){
    loadData();
    //print('    Searching for Selections');
    item.reference.collection('selections').snapshots().forEach((querySnapshot){
      querySnapshot.documents.forEach((snapshot){
        //print('      Found the selection ${snapshot.documentID}: ${snapshot.data}');
        if(!selections.contains(Selection.fromSnapshot(snapshot))){
          setState(() {
            selections.add(Selection.fromSnapshot(snapshot));
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        color: item.prepared?Colors.black45:Colors.transparent,
        child: InkWell(
            child:Padding(
          padding: EdgeInsets.all(4.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: item.prepared?Colors.black:Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('${item.quantity.toString()}', style: Theme
                            .of(context)
                            .textTheme
                            .subhead,),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('${_itemName}${item.quantity>1?'s':''}', style: Theme
                            .of(context)
                            .textTheme
                            .title,),
                        //${item.quantity>1?'(${item.quantity}x @ ${(item.price).toStringAsFixed(2)})':''}
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '\$${(item.price * item.quantity.toDouble())
                          .toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.subtitle.apply(color: item.prepared?Colors.black:Colors.grey),),
                    ),
                    widget.accepted?Icon(item.prepared?Icons.check_box:Icons.check_box_outline_blank):Container(),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: selections.map((selection) =>
                        SelectionTile(selection)).toList(),
                  ),
                ),
              ],
            ),

          ),
          onTap: widget.accepted?() {
            setState(() {
              item.toggleItemPrepared();
            });
          }:null,
        ),
      ),
    );
  }
}