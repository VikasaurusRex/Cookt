import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stripe_payment/stripe_payment.dart';

class Payment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>_PaymentState();
}

class _PaymentState extends State<Payment> {

  // TODO: Implement Stripe API from Video and save to user

  _PaymentState(){

  }

  @override
  Widget build(BuildContext context) {
    StripeSource.addSource().then((String token) {
      Map<String, dynamic> map = Map();
      map['custId'] = token;
      Firestore.instance.collection('cards').document('usercustomer').setData(map);
    });
    return Scaffold(
      appBar: AppBar(title: Text('Payment'),),
      body: Container(),
    );
  }
}