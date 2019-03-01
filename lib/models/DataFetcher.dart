import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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
        future: FirebaseStorage.instance.ref().child("images").child("$foodId-0.png").getDownloadURL(),
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
        future: FirebaseStorage.instance.ref().child("images").child("$foodId-$imageNum.png").getDownloadURL(),
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
      );
    }
    return FutureBuilder(
        future: FirebaseStorage.instance.ref().child("profilepics").child("$uid.png").getDownloadURL(),
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

  static Future<String> nameAbbreviated(String uid) async {
    Event nameEvent = await FirebaseDatabase.instance.reference().child(uid).child('userinfo').onValue.asBroadcastStream().first;
    return '${nameEvent.snapshot.value['firstname']} ${nameEvent.snapshot.value['lastname'].toString().substring(0,1)}.';
  }
}