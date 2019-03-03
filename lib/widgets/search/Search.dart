import 'package:flutter/material.dart';

import 'SearchCategories.dart';

class Search extends StatefulWidget {

  Search();

  @override
  State<StatefulWidget> createState() =>_SearchState();
}

class _SearchState extends State<Search> {

  bool isSearching = false;
  TextEditingController searchField = TextEditingController();

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
                  searchField.text = text;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _currentSearch(){
    return Container(
      child: Center(
        child: Text(searchField.text),
      ),
    );
  }
}