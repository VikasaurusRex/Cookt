import 'package:flutter/material.dart';

import 'package:cookt/models/orders/Item.dart';
import 'package:cookt/models/DatabaseIntegrator.dart';
import 'package:cookt/models/orders/Selection.dart';

class ItemTile extends StatefulWidget {
  final Item item;
  final Function(Item) deleteItem;
  final Function calculatePrice;
  final bool allowModification;

  Key key;

  ItemTile(this.item, this.deleteItem, this.allowModification, {@required this.key, this.calculatePrice});

  @override
  State<StatefulWidget> createState() =>_ItemTileState(item);
}

class _ItemTileState extends State<ItemTile> {
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

  _ItemTileState(this.item){
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
//        decoration: BoxDecoration(
//          border: Border.all(color: Colors.grey),
//          borderRadius: BorderRadius.circular(5.0),
//        ),
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Row(
                        children: <Widget>[
                          widget.allowModification ?InkWell(
                            child: Icon(Icons.remove),
                            onTap: () {
                              setState(() {
                                if (item.quantity == 1) {
                                  _confirmDelete();
                                  return;
                                }
                                item.decrementQuantity();
                                widget.calculatePrice();
                              });
                            },
                          ) : Container(),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('${item.quantity.toString()}', style: Theme
                                .of(context)
                                .textTheme
                                .subhead,),
                          ),
                          widget.allowModification? InkWell(
                            child: Icon(Icons.add),
                            onTap: () {
                              setState(() {
                                item.incrementQuantity();
                                widget.calculatePrice();
                              });
                            },
                          ) : Container(),
                        ]
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
                    child: Text('\$${(item.price * item.quantity.toDouble())
                        .toStringAsFixed(2)}', style: Theme
                        .of(context)
                        .textTheme
                        .title,),
                  ),
                  widget.allowModification ? InkWell(
                    child: Icon(Icons.cancel),
                    onTap: () {
                      _confirmDelete();
                    }, //widget.deleteItem(item),
                  ) : Container(),
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
      ),
    );
  }

  Future<void> _confirmDelete() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete the item?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                widget.deleteItem(item);
                item.decrementQuantity();
                item.deleteItem();
                widget.calculatePrice();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: (){
                // set to false
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}

class SelectionTile extends StatelessWidget {
  final Selection selection;

  SelectionTile(this.selection);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${selection.title}:', style: Theme.of(context).textTheme.subtitle.apply(fontSizeFactor: 1.05, fontWeightDelta: 2),),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selection.selections.map((selection) => Text('$selection', style: Theme.of(context).textTheme.subtitle,)).toList(),
          )
        ],
      )
    );
  }
}