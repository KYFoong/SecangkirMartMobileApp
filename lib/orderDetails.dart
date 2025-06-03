import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Orderdetails extends StatefulWidget {
  final String orderId;

  const Orderdetails({super.key, required this.orderId});

  @override
  State<Orderdetails> createState() => _OrderdetailsState();
}

class _OrderdetailsState extends State<Orderdetails> {
  Map<String, dynamic> orderDocument = {};
  bool isLoading = true;  // Flag to track loading state
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      DocumentSnapshot docRef = await FirebaseFirestore.instance
        .collection('Order')
        .doc(widget.orderId)
        .get();

      if (docRef.exists) {
        setState(() {
          orderDocument = docRef.data() as Map<String, dynamic>;
          isLoading = false;  // Data is now loaded
        });
        // Check if the product field exists and is an array
        if (orderDocument.containsKey('products') && orderDocument['products'] is List) {
          setState(() {
            products = List<Map<String, dynamic>>.from(orderDocument['products']);
            isLoading = false;  // Stop loading once data is fetched
          });
        } 

        // if (orderDocument.containsKey('paymentMethod') && orderDocument['paymentMethod'] is DocumentReference) {
        //   DocumentReference paymentRef = orderDocument['paymentMethod'] as DocumentReference;
        //
        //   DocumentSnapshot paymentDocRef = await paymentRef.get();
        //   if (paymentDocRef.exists) {
        //     setState(() {
        //       // Fetch payment type (e.g., card, Touch n Go)
        //       String paymentType = paymentDocRef['type'];
        //       String paymentDetails = '';
        //
        //       // Display card number or phone number based on the payment type
        //       if (paymentType.contains('Card')) {
        //         paymentDetails = '*${paymentDocRef['cardNum'].toString().substring(paymentDocRef['cardNum'].length - 4)}';
        //       } else {
        //         paymentDetails = '*${paymentDocRef['phoneNumber'].toString().substring(paymentDocRef['phoneNumber'].length - 4)}';
        //       }
        //
        //       // Store the payment type and details for display
        //       orderDocument['paymentType'] = paymentType;
        //       orderDocument['paymentDetails'] = paymentDetails;
        //     });
        //   }
        // }

      } else {
        setState(() {
          isLoading = false;  // Stop loading if order document is not found
        });
      }
      print(orderDocument);
      print(products);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching order details: $e')),
      );
      setState(() {
        isLoading = false;  // Stop loading on error
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<dynamic> products = orderDocument['products'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Details', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
            )
          ),
        backgroundColor: const Color(0xFFC59D54),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined
          ),
          iconSize: 32,
          color: const Color.fromARGB(255, 255, 255, 255),
          ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 2
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        decoration: TextDecoration.underline, 
                      ),
                    ),
        
                    const SizedBox(height: 5,),
              
                    Text('Order Number: ON${orderDocument['orderCode'].toString().padLeft(4, '0')}',
                      style: summText()
                    ),

                    // Text('Payment Method: ${orderDocument['paymentType']} ${orderDocument['paymentDetails']}',
                    //   style: summText()
                    // ),
              
                    Text('Quantity: ${orderDocument['totalProducts']}',
                      style: summText()
                    ),
              
                    Text(
                      'Date Ordered: ${orderDocument['placedOn'] != null 
                        ? DateFormat('MMM dd, yyyy hh:mm a').format(orderDocument['placedOn']!.toDate()) 
                        : 'Not available'}',
                      style: summText()
                    ),
              
                    Text('Total Amount: RM ${orderDocument['totalPrice'].toStringAsFixed(2)}',
                      style: summText()
                    ),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Status: ',  // This part will have the default style
                            style: summText().copyWith(color: Colors.black)
                          ),
                          TextSpan(
                            text: '${orderDocument['orderStatus']}',  // This part will have a different color
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: orderDocument['orderStatus'] == 'Processing' ? 
                                const Color.fromARGB(255, 194, 5, 5) : 
                                const Color.fromARGB(255, 5, 194, 5) // Change this to whatever color you want
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Order Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              ),

              ...products.map((product) => itemDetail(product)),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemDetail(Map<String, dynamic> product){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.network(
                product['image'],
                width: 100,
                height: 100,
              ),

              const SizedBox(width: 10,),
      
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                    ),
                
                    Text('${product['cat']}'),
                
                    Text('Quantity: ${product['quantity']}'),
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('RM ${product['price'].toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  TextStyle summText(){
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16
    );
  }
}