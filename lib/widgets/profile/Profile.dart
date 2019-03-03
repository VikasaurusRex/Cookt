import 'package:flutter/material.dart';
import 'package:cookt/models/DataFetcher.dart';

class Profile extends StatefulWidget {

  Profile();

  @override
  State<StatefulWidget> createState() =>_ProfileState();
}

class _ProfileState extends State<Profile> {
  String _name = "Loading...";
  String userid;

  void loadData() {
    DataFetcher.nameFull('usercook').then((val) => setState(() {
      _name = val;
    }));
  }

  _ProfileState(){
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Container(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(MediaQuery.of(context).size.height),
                    child: DataFetcher.userImage('usercook'),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0,0,0,8),
            child: Text(_name, style: Theme.of(context).textTheme.title, textAlign: TextAlign.center,),
          ),
          Container(height: 1, color: Colors.grey,),
          ProfileButton(Icons.favorite_border, 'Favorites'),
          ProfileButton(Icons.credit_card, 'Payment'),
          ProfileButton(Icons.person, 'Help'),
          ProfileButton(Icons.settings, 'Settings'),
          ProfileButton(Icons.location_on, 'Address'),
          ProfileButton(Icons.attach_money, 'Sell Your Food'),
          ProfileButton(Icons.person_outline, 'Log Out'),
          Expanded(child: Container(),)
        ],
      ),
    );
  }
}

class ProfileButton extends StatelessWidget{
  IconData icon;
  String label;

  ProfileButton(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        height: 45,
        child: FlatButton(
          onPressed: (){
            print(label);
          },
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 20, 8),
                child: Icon(icon, size: 30,),
              ),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.title,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}