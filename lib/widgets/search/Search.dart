import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'SearchCategories.dart';
import 'FoodItemList.dart';


class Search extends StatefulWidget {

  Search();

  @override
  State<StatefulWidget> createState() =>_SearchState();
}

class _SearchState extends State<Search> {

  bool isSearching = false;
  TextEditingController searchField = TextEditingController(text: 'Burrito');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searchBar(),
      ),
      body: isSearching? _currentSearch():SearchHome(),
    );
  }

  Widget _searchBar(){
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(4.0),
            child: isSearching?
            AspectRatio(
              aspectRatio: 1,
              child: FlatButton(
                padding: EdgeInsets.all(0),
                onPressed: (){
                  setState(() {
                    isSearching = false;
                  });
                },
                child: Icon(Icons.cancel, size: 25,),
              ),
            )
                :
            AspectRatio(
              aspectRatio: 1,
              child: Icon(
                Icons.search,
                color: Theme.of(context).primaryColorDark,
                size: 25,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: searchField,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search',
                  hintStyle: Theme.of(context).textTheme.title.apply( color: Theme.of(context).primaryColorDark)
              ),
              onTap: (){
                setState(() {
                  isSearching = true;
                });
              },
              onChanged: (text){
                setState(() {
                  isSearching = true;
                  // TODO: Remove Comment
                  //searchField.text = text;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _currentSearch(){
    List<Query> searchComponents = [
      Firestore.instance.collection('fooddata').where('name', isEqualTo: searchField.text)
    ];
    return FoodItemList(searchComponents, key: Key(searchComponents.toString()));
  }
}