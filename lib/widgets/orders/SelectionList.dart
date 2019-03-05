import 'package:flutter/material.dart';

import 'package:cookt/models/orders/Item.dart';
import 'package:cookt/models/orders/Selection.dart';

class SelectionList extends StatefulWidget {
  final Item item;

  SelectionList(this.item);

  @override
  State<StatefulWidget> createState() =>_SelectionListState(item);
}

class _SelectionListState extends State<SelectionList> {
  final Item item;
  List<Selection> selections = List();

  _SelectionListState(this.item){
    print('    Searching for Selections');
    item.reference.collection('selections').snapshots().forEach((querySnapshot){
      querySnapshot.documents.forEach((snapshot){
        print('      Found the selection ${snapshot.documentID}: ${snapshot.data}');
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
    return Container(
      child: Column(
        children: selections.map((selection) => SelectionTile(selection)).toList(),
      )
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
            Text('${selection.title}:', style: Theme.of(context).textTheme.title,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: selection.selections.map((selection) => Text('  $selection', style: Theme.of(context).textTheme.subtitle,)).toList(),
            )
          ],
        )
    );
  }
}