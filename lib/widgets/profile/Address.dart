import 'package:flutter/material.dart';

import 'package:geocoder/geocoder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:cookt/models/User.dart';
import 'package:cookt/models/DatabaseIntegrator.dart';

class Address extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>_AddressState();
}

class _AddressState extends State<Address> {

  TextEditingController addressController = TextEditingController();
  GoogleMapController mapController;
  LatLng cookCoords;
  Marker cookPosition;

  _AddressState(){
    DatabaseIntegrator.loc('usercook').then((val) => setState(() {
      cookCoords = LatLng(val.latitude, val.longitude);
      updateMap();
    }));
  }

  @override
  Widget build(BuildContext context) {
    updateMap();
    return Scaffold(
      appBar: AppBar(title: Text('Help'),),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Change Address', style: Theme.of(context).textTheme.title.apply(fontWeightDelta: 1),),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: _address(),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: _map(),
            ),
            RaisedButton(
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text('Change Address'),
              ),
              onPressed: changeAddress,
            )
          ],
        ),
      ),
    );
  }

  void changeAddress() {
    User.updateAddress(GeoPoint(cookCoords.latitude, cookCoords.longitude), uid: 'usercook');
    Navigator.of(context).pop();
    _confirmAddressChange();
  }

  Widget _address(){
    return TextField(
      keyboardType: TextInputType.text,
      maxLines: 1,
      controller: addressController,
      onEditingComplete: (){
        Geocoder.local.findAddressesFromQuery(addressController.text).then((addresses){
          Coordinates coors = addresses.first.coordinates;
          cookCoords = LatLng(coors.latitude, coors.longitude);
          updateMap();
        });
        setState(() {});
      },
      onSubmitted: (text){
        addressController.text = text;
        Geocoder.local.findAddressesFromQuery(addressController.text).then((addresses){
          Coordinates coors = addresses.first.coordinates;
          cookCoords = LatLng(coors.latitude, coors.longitude);
          updateMap();
        });
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: "New Address",
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor),),
        labelStyle: TextStyle(color: Theme.of(context).hintColor),
      ),
    );
  }

  Future<void> _confirmAddressChange() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Address Changed.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your address has been updated!'),
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

  Widget _map(){
    return Container(
      height: 200.0,
      child: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        // TODO: Change these map options
        options: GoogleMapOptions(
          mapType: MapType.normal,
          myLocationEnabled: false,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }

  void updateMap() async{
    if(mapController == null || cookCoords == null) {
      print('Cook Coords not loaded');
      return;
    }else {
      mapController.removeMarker(cookPosition);
    }


    cookPosition = await mapController.addMarker(
      MarkerOptions(
        position: cookCoords,
      ),
    );
    mapController.moveCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(cookCoords.latitude, cookCoords.longitude), zoom: 15.0)
    ));
  }
}