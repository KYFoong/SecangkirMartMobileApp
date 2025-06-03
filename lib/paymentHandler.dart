import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<int> generateOrderNumber() async {
  // Get the latest order number from Firestore
  final QuerySnapshot query = await FirebaseFirestore.instance
      .collection('Order')
      .orderBy('placedOn', descending: true)
      .limit(1)
      .get();

  int nextNumber = 1;

  if (query.docs.isNotEmpty) {
    final lastOrder = query.docs.first.data() as Map<String, dynamic>;
    final lastNumber = lastOrder['orderCode'] as int?;
    if (lastNumber != null) {
      nextNumber = lastNumber + 1;
    }
  }

  return nextNumber;
}

Future<void> processPayment({
  required List<String> selectedItems,
  required List<Map<String, dynamic>> products,
  required double totalPrice,
  required int totalQuantity,
  required bool isFromCart,
  required String paymentId
}) async {
  try {
    final batch = FirebaseFirestore.instance.batch();
    final orderNumber = await generateOrderNumber();
    final userID = FirebaseAuth.instance.currentUser!.uid;

    // Create new order document
    final orderRef = FirebaseFirestore.instance.collection('Order').doc();
    batch.set(orderRef, {
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'orderCode': orderNumber,
      'orderStatus': 'Processing',
      'placedOn': Timestamp.now(),
      'totalPrice': totalPrice,
      'totalProducts': totalQuantity,
      'products': products, // Store all product details
      'paymentMethod': FirebaseFirestore.instance.collection('Payment').doc(paymentId)
    });

    // Delete selected items from cart
    if(isFromCart){
      for (String itemId in selectedItems) {
        final cartRef = FirebaseFirestore.instance.collection('cart').doc(itemId);
        batch.delete(cartRef);
      }
    }

    // Commit the batch
    await batch.commit();

  } catch (e) {
    // Handle error
    debugPrint('Error processing payment: $e');
    rethrow; // Rethrow to handle in UI
  }
}