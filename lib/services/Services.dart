import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:cookt/models/foodItems/Review.dart';
import 'package:cookt/models/users/User.dart';

class Services{

  static double rating(String uid) {
    double ratingSum;
    double totalRatings;
    Firestore.instance.collection('fooddata').where('uid', isEqualTo: uid).getDocuments().then((foodItemQuery){
      foodItemQuery.documents.forEach((foodItemSnap){
        foodItemSnap.reference.collection('reviews').getDocuments().then((reviewQuery){
          reviewQuery.documents.forEach((reviewSnap){
            Review review = Review.fromSnapshot(reviewSnap);
            ratingSum += review.rating;
            totalRatings++;
          });
        });
      });
    });
    return ratingSum/totalRatings;
  }

  static Widget foodImage(String imageId) { // FoodItem
    if(imageId == null){
      return Container(
        color: Colors.grey,
        child: Center(child:Icon(Icons.photo)),
      );
    }
    return FutureBuilder(
        future: FirebaseStorage.instance.ref().child("foodpics").child("$imageId.png").getDownloadURL(),
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

  static Widget userImage(String uid) { // Profile
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

  static Widget storefrontImage(String cookID) { // Order
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

  // TODO: Implement function to calculate whether user can or cannot order food item (if too far away)
  static double milesBetween(){
    // ~1 mile of lat and lon in degrees
    double lat = 0.0144927536231884;
    double lon = 0.0181818181818182;
    return 0.0;
  }

  static Future<User> userWithUid(String uid) async { // Order, FoodItem
    DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(uid).get();
    if(!snapshot.exists){
      return null;
    }
    return User.fromSnapshot(snapshot);
  }

  static Future<String> nameAbbreviated(String uid) async { // Order, FoodItem
    DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(uid).get();
    if(!snapshot.exists){
      return 'No Name';
    }
    return '${snapshot.data['firstname']} ${snapshot.data['lastname'].toString().substring(0,1)}.';
  }

  static Future<String> nameFull(String uid) async { // Order, FoodItem
    DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(uid).get();
    if(!snapshot.exists){
      return 'No Name';
    }
    return '${snapshot.data['firstname']} ${snapshot.data['lastname']}';
  }

  static Future<GeoPoint> loc(String uid) async { // FoodItem
    DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(uid).get();
    if(!snapshot.exists || snapshot.data['kitchenname'] == null){
      return null;
    }
    return snapshot.data['loc'];
  }

  static Future<String> kitchenName(String uid) async { // Order, FoodItem
    DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(uid).get();
    if(!snapshot.exists || snapshot.data['kitchenname'] == null){
      return 'No Kitchen Name';
    }
    return snapshot.data['kitchenname'];
  }

  static Future<bool> dineInAvailable(String uid) async { // FoodItem
    DocumentSnapshot snapshot = await Firestore.instance.collection('users').document(uid).get();
    if(!snapshot.exists || snapshot.data['dineInAvailable'] == null){
      return false;
    }
    return snapshot.data['dineInAvailable'];
  }

  static Future<String> foodName(String foodId) async{ // Order
    DocumentSnapshot foodItem = await Firestore.instance.collection('fooddata').document(foodId).get();
    if(!foodItem.exists || foodItem.data['name'] == null){
      return 'No Food Name';
    }
    return foodItem.data['name'];
  }

  static Future<double> cooktRate() async{ // Order
    DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child('properties').once();
    if(snapshot.value['cooktrate'] == null){
      return -1;
    }
    return snapshot.value['cooktrate'].toDouble();
  }
  static Future<double> cooktConstant() async{ // Order
    DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child('properties').once();
    if(snapshot.value['cooktconstant'] == null){
      return -1;
    }
    return snapshot.value['cooktconstant'].toDouble();
  }
  static Future<double> stripeRate() async{ // Order
    DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child('properties').once();
    if(snapshot.value['striperate'] == null){
      return -1;
    }
    return snapshot.value['striperate'].toDouble();
  }
  static Future<double> otherConstant() async{ // Order
    DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child('properties').once();
    if(snapshot.value['stripeconstant'] == null){
      return -1;
    }
    return snapshot.value['stripeconstant'].toDouble();
  }

  static String simplifiedDate(DateTime date){ // Order
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

  static String onlyTime(DateTime date){ // Order
    return '${date.hour%12==0?'12':date.hour%12}${date.minute==0? '': ':${date.minute}'} ${date.hour>11?'PM':'AM'}';
  }

  static String dayOfTheWeek(int weekday){ // Order
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
}