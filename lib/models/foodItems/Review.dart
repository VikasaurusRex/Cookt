import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final int rating;
  final String review;
  final String userid;
  final DateTime time;

  DocumentReference reference;

  Review.fromMap(Map<String, dynamic> map, {@required this.reference}) :
        assert(map['rating'] != null),
        assert(map['review'] != null),
        assert(map['userid'] != null),
        assert(map['time'] != null),
        this.rating = map['rating'],
        this.review = map['review'],
        this.userid = map['userid'],
        this.time = map['time'];

  Review.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  Review.from(int rating, String review) :
        this.rating = rating,
        this.review = review,
        this.userid = 'usercustomer',
        this.time = DateTime.now(),
        this.reference = null;

  @override
  String toString() => "$userid : $rating";

  Future<DocumentReference> create(DocumentReference reference) async {
    Map<String, dynamic> map = Map();
    map['rating'] = rating;
    map['review'] = review;
    map['userid'] = userid;
    map['time'] = time;

    reference.collection('reviews').add(map).then((ref){
      this.reference = ref;
      return ref;
    });
  }

  void updateReview(String review, int rating) {
    Map<String, dynamic> map = Map();
    map['rating'] = rating;
    map['review'] = review;
    map['time'] = DateTime.now();

    reference.updateData(map);
  }

  bool operator ==(other) {
    return (other is Review && other.reference == reference);
  }
}