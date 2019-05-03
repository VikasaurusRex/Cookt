import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DataFetcher{

  static Widget foodImage(String foodId) {
    if(foodId == null){
      return Container(
        color: Colors.grey,
      );
    }
    return FutureBuilder(
        future: FirebaseStorage.instance.ref().child("foodpics").child("$foodId-0.png").getDownloadURL(),
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

  static Widget foodImageAt(String foodId, int imageNum) {
    if(foodId == null){
      return Container(
        color: Colors.grey,
      );
    }
    return FutureBuilder(
        future: FirebaseStorage.instance.ref().child("foodpics").child("$foodId-$imageNum.png").getDownloadURL(),
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
    if(!snapshot.exists || snapshot.data['kitchenname'] == null){
      return 'No Name';
    }
    return '${snapshot.data['firstname']} ${snapshot.data['lastname']}';
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