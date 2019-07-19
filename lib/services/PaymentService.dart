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

  buyItem(price){
    int processedPrice = price * 100;

    Map<String ,dynamic> map = Map();
    map['currency'] = 'usd';
    map['amount'] = processedPrice;
    map['description'] = 'Purchase of product'; // TODO: Edit this description

    Firestore.instance.collection('users')
        .document('usercustomer')
        .collection('charges').add(map);
  }

}