import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cookt/models/foodItems/FoodItem.dart';
import 'CategoryTile.dart';
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
      body: isSearching? _currentSearch()
          :
      Container(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2,
            children: FoodItem.allCategories.map((category) => CategoryTile(category, (){
              setState(() {
                searchField.text = category;
                isSearching = true;
              });
            })).toList(),
          ),
        ),
      ),
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
                    searchField.text = '';
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
              textCapitalization: TextCapitalization.words,
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
                  searchField.text = text;
                  print('Search Bar: $text');
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
      Firestore.instance.collection('fooddata').orderBy('name').startAt([searchField.text]).endAt([searchField.text.length <=0? '': searchField.text+'\uf8ff']),
      Firestore.instance.collection('fooddata').where('categories', arrayContains: searchField.text),
      Firestore.instance.collection('fooddata').where('price', isLessThanOrEqualTo: isNum(searchField.text)?double.parse(searchField.text):-0.1),
    ];
    return FoodItemList(searchComponents, key: Key(searchField.text));
  }

  bool isNum(String text){
    try{
      var value = double.parse(text);
    } on FormatException {
      return false;
    }
    return true;
  }
}