const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

const firestore = admin.firestore();
const settings = { timestampInSnapshots: true };
firestore.settings(settings);

const stripe = require('stripe')(functions.config().stripe.token);

exports.addStripeSource = functions.firestore.document('users/{userid}/tokens/{tokenid}').onCreate(async (tokenSnap, context) => {

    var customer;
    const data = tokenSnap.data();
    if (data === null) {
        return null;
    }

    const token = data.tokenId;
    // TODO: context.params.userId instead of 'usercustomer'
    const snapshot = await firestore.collection('users').doc('usercustomer').get();
    const customerId = snapshot.data().custId;
    const customerEmail = snapshot.data().email;

    if(customerId === null){
        customer = await stripe.customers.create({
            email: customerEmail,
            source: token
        }); // context.params.userId
        firestore.collection('users').doc('usercustomer').update({
            custId: customer.id
        });
    } else {
        customer = await stripe.customers.retrieve(customerId);
    }

    const customerSource = customer.sources.data[0];

    //tokenSnap.ref.set({'status':'Made it to end'},{merge:true});
    return firestore.collection('users').doc('usercustomer').collection('sources').doc(customerSource.card.fingerprint).set(customerSource, {merge: true});
});

exports.createCharge = functions.firestore.document('users/{userId}/charges/{chargeId}')
    .onCreate(async (chargeSnap, context) => {
        try {
                                                        // TODO: context.params.userId
            const cardSnap = await firestore.collection('users').doc('usercustomer').get();
            const customer = cardSnap.data().custId;
            const amount = chargeSnap.data().amount;
            const currency = chargeSnap.data().currency;
            const description = chargeSnap.data().description;

            const charge = {amount, currency, customer, description};
            const idempotentKey = context.params.chargeId;

            const response = await stripe.charges.create(charge, {idempotency_key: idempotentKey});
            return chargeSnap.ref.set(response, {merge: true});

        } catch (error) {
            await chargeSnap.ref.set({error: error.message }, { merge: true});
        }
    });
