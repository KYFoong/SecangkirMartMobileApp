import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PaymentController extends GetxController {
  Map<String, dynamic>? paymentIntentData;

  // Initiates the payment process
  Future<bool> makePayment({required String amount, required String currency}) async {
    try {
      // 1. Create payment intent
      paymentIntentData = await createPaymentIntent(amount, currency);
      if (paymentIntentData != null) {
        // 2. Initialize payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            merchantDisplayName: 'Prospects',
            customerId: paymentIntentData!['customer'],
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
          ),
        );

        // 3. Show payment sheet and await result
        bool result = await displayPaymentSheet();
        return result;
      }
      return false;
    } catch (e) {
      print('Error in makePayment: $e');
      return false;
    }
  }


  // Handles displaying the payment sheet and returns success or failure
  Future<bool> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      Get.snackbar('Payment', 'Payment Successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2));
      return true; // Indicate payment success
    } on StripeException catch (e) {
      print("Error from Stripe: ${e.error.localizedMessage}");
      Get.snackbar('Payment', 'Payment Failed: ${e.error.localizedMessage}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2));
      return false; // Indicate payment failure
    } catch (e) {
      print("Error: $e");
      Get.snackbar('Payment', 'Payment Failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2));
      return false; // Indicate payment failure
    }
  }

  // Creates a payment intent on Stripe's server
  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      double parsedAmount = double.parse(amount);
      Map<String, dynamic> body = {
        'amount': calculateAmount(parsedAmount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer sk_test_51Qf2x8Rr69N5fVT6XGHSAt8EyI1lUfDXarZz3ZX9vULmRzf1sbi7ChCCeAb9HK8Ps8xoDA94KOHb9JB9VH2S1VHz00hd3rQ3or', 
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return jsonDecode(response.body);
    } catch (err) {
      print('Error while creating payment intent: ${err.toString()}');
      return null;
    }
  }

  // Converts amount to cents
  String calculateAmount(num amount) {
    int amountInCents = (amount * 100).toInt();
    return amountInCents.toString();
  }
}

