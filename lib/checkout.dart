import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'button.dart';
import 'paymentHandler.dart';
import 'paymentSuccess.dart';
import 'paymentController.dart';

class CheckOut extends StatefulWidget {
  final List<String> selectedItems;
  final bool isFromCart;
  final int? quantity;

  const CheckOut(
      {super.key,
        required this.selectedItems,
        required this.isFromCart,
        this.quantity});

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  List<Map<String, dynamic>> products = [];
  double totalPrice = 0;
  int totalQuantity = 0;

  final paymentController = Get.put(PaymentController());

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      if (widget.isFromCart) {
        // Fetch from cart collection
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('cart')
            .where(FieldPath.documentId, whereIn: widget.selectedItems)
            .get();

        final List<Map<String, dynamic>> fetchedProducts = [];
        double price = 0;
        num quantity = 0;

        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final double adjustedPrice =
          ((data['price'] ?? 0.0) * (data['quantity'] ?? 1)).toDouble();
          fetchedProducts.add({
            ...data,
            'price': adjustedPrice,
          });

          price += adjustedPrice;
          quantity += data['quantity'] ?? 1;
        }

        setState(() {
          products = fetchedProducts;
          totalPrice = price;
          totalQuantity = int.parse(quantity.toString());
        });
      } else {
        // Fetch from Category collection (Buy Now)
        String itemId = widget.selectedItems.first;
        final docSnap = await FirebaseFirestore.instance
            .collection('Category')
            .doc(itemId)
            .get();

        if (docSnap.exists) {
          Map<String, dynamic> product = docSnap.data() as Map<String, dynamic>;
          product['price'] = (product['price'] * widget.quantity).toDouble();
          product['quantity'] = widget.quantity ?? 1;

          setState(() {
            products = [product];
            totalPrice = (product['price'] ?? 0).toDouble();
            totalQuantity = widget.quantity ?? 1;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFC59D54),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_outlined),
          iconSize: 32,
          color: Colors.white,
        ),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              'Order Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return itemDetail(products[index]);
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Items: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Amount: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalQuantity',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'RM ${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Trigger the payment process and await the result
                  bool paymentSuccess = await paymentController.makePayment(
                    amount: totalPrice.toString(),
                    currency: 'MYR',
                  );

                  if (paymentSuccess) {
                    // Get a payment ID from the payment gateway, assuming it’s part of the response or process
                    String paymentId = "yourPaymentId"; // Replace with actual payment ID

                    // Process the payment and save the order details in Firestore
                    await processPayment(
                      selectedItems: widget.selectedItems,
                      products: products,
                      totalPrice: totalPrice,
                      totalQuantity: totalQuantity,
                      isFromCart: widget.isFromCart,
                      paymentId: paymentId,
                    );

                    // Navigate to PaymentSuccess page after successful payment
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentSuccess(totalAmount: totalPrice),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment was not successful.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Payment failed: ${e.toString()}'),
                    ),
                  );
                }
              },
              style: payButton,
              child: const Text(
                'Pay',
                style: TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemDetail(Map<String, dynamic> product) {
    final productName = product['name'] ?? 'Product Name';
    final productCat = product['cat'] ?? 'Category';
    final num price = product['price'] ?? 0.00;
    int quantity = product['quantity'] ?? 1;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.network(
            product['image'],
            width: 100,
            height: 100,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    productCat,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Quantity: $quantity',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'RM ${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}