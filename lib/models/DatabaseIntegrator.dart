import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class DatabaseIntegrator{

  static Widget foodImage(String imageId) {
    if(imageId == null){
      return Container(
        color: Colors.grey,
      );
    }
    return FutureBuilder(
        future: FirebaseStorage.instance.ref().child("foodpics").child("$imageId.png").getDownloadURL(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> imageData) {
          if(imageData.hasError || !imageData.hasData){
            return Container(
              color: Colors.grey,
            );
          }
          return Image.network(
            imageData.data.toString(),
            fit: BoxFit.cover,
          );
        }
    );
  }

  static Widget userImage(String uid) {
    if(uid == null){
      return Container(
        color: Colors.grey,
        child: Center(child:Icon(Icons.photo)),
      );
    }
    return FutureBuilder(
        future: FirebaseStorage.instance.ref().child("profilepics").child("$uid.png").getDownloadURL(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> imageData) {
          if(imageData.hasError || !imageData.hasData){
            return Container(
              color: Colors.grey,
              child: Center(child:Icon(Icons.photo)),
            );
          }
          return Image.network(
            imageData.data.toString(),
            fit: BoxFit.cover,
          );
        }
    );
  }

  static Widget storefrontImage(String cookID) {
    if(cookID == null){
      return Container(
        color: Colors.grey,
        child: Center(child:Icon(Icons.photo)),
      );
    }
    return FutureBuilder(
        future: FirebaseStorage.instance.ref().child("storefrontpics").child("$cookID.png").getDownloadURL(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> imageData) {
          if(imageData.hasError || !imageData.hasData){
            return Container(
              color: Colors.grey,
              child: Center(child:Icon(Icons.photo)),
            );
          }
          return Image.network(
            imageData.data.toString(),
            fit: BoxFit.cover,
          );
        }
    );
  }

  static Future<String> nameAbbreviated(String uid) async {
    DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(uid).get();
    if(!snapshot.exists || snapshot.data['kitchenname'] == null){
      return 'No Name';
    }
    return '${snapshot.data['firstname']} ${snapshot.data['lastname'].toString().substring(0,1)}.';
  }

  static Future<String> nameFull(String uid) async {
    DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(uid).get();
    if(!snapshot.exists){
      return 'No Name';
    }
    return '${snapshot.data['firstname']} ${snapshot.data['lastname']}';
  }

  static Future<LatLng> loc(String uid) async {
    DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(uid).get();
    if(!snapshot.exists || snapshot.data['kitchenname'] == null){
      return null;
    }
    return LatLng(snapshot.data['lat'], snapshot.data['long']);
  }

  static Future<String> kitchenName(String uid) async {
    DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(uid).get();
    if(!snapshot.exists || snapshot.data['kitchenname'] == null){
      return 'No Kitchen Name';
    }
    return snapshot.data['kitchenname'];
  }

  static Future<bool> dineInAvailable(String uid) async {
    DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(uid).get();
    if(!snapshot.exists || snapshot.data['dineInAvailable'] == null){
      return false;
    }
    return snapshot.data['dineInAvailable'];
  }

  static Future<String> foodName(String foodId) async{
    DocumentSnapshot foodItem = await Firestore.instance.collection('fooddata').document(foodId).get();
    if(!foodItem.exists || foodItem.data['name'] == null){
      return 'No Food Name';
    }
    return foodItem.data['name'];
  }

  static Future<double> cooktTake() async{
    DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child('properties').once();
    print('In int ${snapshot.value['cookttake'].toDouble()}');
    if(snapshot.value['cookttake'] == null){
      return -1;
    }
    return snapshot.value['cookttake'].toDouble();
  }

  static String simplifiedDate(DateTime date){
    String month;
    String fullDate;

    switch (date.month){
      case 1: { month = 'Jan'; }
      break;
      case 2: { month = 'Feb'; }
      break;
      case 3: { month = 'Mar'; }
      break;
      case 4: { month = 'Apr'; }
      break;
      case 5: { month = 'May'; }
      break;
      case 6: { month = 'June'; }
      break;
      case 7: { month = 'July'; }
      break;
      case 8: { month = 'Aug'; }
      break;
      case 9: { month = 'Sep'; }
      break;
      case 10: { month = 'Oct'; }
      break;
      case 11: { month = 'Nov'; }
      break;
      case 12: { month = 'Dec'; }
      break;
      default: { month = '---'; }
      break;
    }

    fullDate = '${month} ${date.day}, ${date.year}';

    if (date.month == DateTime.now().month && date.day == DateTime.now().day && date.year == DateTime.now().year){
      fullDate = 'Today';
    }

    return '$fullDate at ${date.hour%12==0?'12':date.hour%12}${date.minute==0? '': ':${date.minute}'} ${date.hour>11?'PM':'AM'}';
  }

  static String dayOfTheWeek(int weekday){
    switch(weekday){
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'ERROR';
    }
  }

//  Widget pickupTimeFromNow(BuildContext context){
//    return StreamBuilder<String>(
//      stream: Stream<String>.periodic(
//        Duration(seconds: 1), (int numRepeats) {
//          final remaining = pickupTime.difference(DateTime.now());
//
//          if(remaining.isNegative){
//            return "ASAP";
//          }
//
//          final hours = remaining.inHours - remaining.inDays * 24;
//          final minutes = remaining.inMinutes - remaining.inHours * 60;
//          final seconds = remaining.inSeconds - remaining.inMinutes * 60;
//
//          final formattedRemaining = 'In $hours hours, $minutes minutes';
//          return formattedRemaining;
//        }
//      ).asBroadcastStream(),
//    builder: (BuildContext context, AsyncSnapshot<String> text) => Text(
//      "${text.data}",
//      style: Theme.of(context).textTheme.subhead,
//    ),
//    );
//  }
}