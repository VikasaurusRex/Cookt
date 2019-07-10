import 'package:flutter/material.dart';
import 'package:cookt/models/DatabaseIntegrator.dart';
import 'package:cookt/services/PaymentService.dart';

import 'package:stripe_payment/stripe_payment.dart';

import 'package:cookt/widgets/sell/SaleHome.dart';

import 'package:cookt/widgets/profile/Favorites.dart';
import 'package:cookt/widgets/profile/Payment.dart';
import 'package:cookt/widgets/profile/Help.dart';
import 'package:cookt/widgets/profile/Settings.dart';
import 'package:cookt/widgets/profile/Address.dart';

class Profile extends StatefulWidget {

  Profile();

  @override
  State<StatefulWidget> createState() =>_ProfileState();
}

class _ProfileState extends State<Profile> {
  String _name = "Loading...";
  String userid;

  void loadData() {
    DatabaseIntegrator.nameFull('usercook').then((val) => setState(() {
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
                    borderRadius: new BorderRadius.circular(10),
                    child: DatabaseIntegrator.userImage('usercook'),
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
          ProfileButton(
            icon: Icons.favorite_border,
            label: 'Favorites',
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Favorites();
                  },
                ),
              );
            },
          ),
          ProfileButton(
            icon: Icons.credit_card,
            label: 'Payment',
            onTap: (){
              StripeSource.addSource().then((String token) {
                PaymentService().addCard(token);
              });
            },
          ),
          ProfileButton(
            icon: Icons.person,
            label: 'Help',
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Help();
                  },
                ),
              );
            },
          ),
          ProfileButton(
            icon: Icons.settings,
            label: 'Settings',
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Settings();
                  },
                ),
              );
            },
          ),
          ProfileButton(
            icon: Icons.location_on,
            label: 'Address',
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Address();
                  },
                ),
              );
            },
          ),
          ProfileButton(
            icon: Icons.attach_money,
            label: 'Sell Your Food',
            onTap: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return SaleHome();
                  },
                ),
              );
            },
          ),
          ProfileButton(
            icon: Icons.person_outline,
            label: 'Log Out',
            onTap: null,
          ),
          Expanded(child: Container(),)
        ],
      ),
    );
  }
}

class ProfileButton extends StatelessWidget{
  IconData icon;
  String label;
  VoidCallback onTap;

  ProfileButton({this.icon, this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
      child: Container(
        height: 45,
        child: FlatButton(
          onPressed: onTap,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10, 8, 20, 8),
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