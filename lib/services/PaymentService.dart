import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  addCard(String token) {
    Firestore.instance.collection('users')
        .document('usercustomer')
        .collection('tokens')
        .add({'tokenId': token}).then((val) {
       print('Successfully added card.');
    });
  }


}