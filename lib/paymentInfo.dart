import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'paymentInfoDetails.dart';

class PaymentDetails extends StatefulWidget {
  const PaymentDetails({super.key});

  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  List<Map<String, dynamic>> currentPayments = [];

  @override
  void initState() {
    super.initState();
    fetchPaymentMethods(); // Fetch payment methods on initialization
  }

  // Fetch payment methods from Firestore
  Future<void> fetchPaymentMethods() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Replace with your user ID or authentication method
      String userId = FirebaseAuth.instance.currentUser!.uid; 

      QuerySnapshot snapshot = await firestore
          .collection('Payment')
          .where('userId', isEqualTo: userId) // Filter by user ID
          .get();

      setState(() {
        currentPayments = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          return data;
        }).toList();
        print(currentPayments);
      });
    } catch (e) {
      print('Error fetching payment methods: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Information', 
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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Payment Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
        
            if (currentPayments.isEmpty)
              const Text('No current payment methods available.')
            else
              ...currentPayments.map((payment) {
                String displayText;
                if (payment['type'] == 'Touch n Go') {
                  displayText = '*${payment['phoneNumber'].toString().substring(payment['phoneNumber'].length - 4)}'; // For Touch n Go
                } else {
                  displayText = '*${payment['cardNum'].toString().substring(payment['cardNum'].length - 4)}'; // For cards
                }

                return paymentRecord(true, 
                  displayText, 
                  payment['type'],
                  payment['id'],
                  payment
                );
              }),

            const SizedBox(height: 40,),

            const Text('Add New Payment Method',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),

            paymentRecord(false, 'Add Visa Card', 'Visa'),
            paymentRecord(false, 'Add Master Card', 'Master'),

            if (!currentPayments.any((payment) => payment['type'] == 'Touch n Go'))
              paymentRecord(false, 'Add Touch n Go', 'Touch n Go'),
          ],
        ),
      ),
    );
  }

  Widget paymentRecord(bool isExist, String label, [String? img, String? documentId, Map<String, dynamic>? paymentData]){
    String type;
    if(paymentData != null){
      type = paymentData['type'];
    }else{
      type = label.substring(4);
    }

    // Determine image path based on the label
    String imagePath;
    if (img!.contains('Touch n Go')) {
      imagePath = 'lib/assets/TnG.png';
    } else if (img.contains('Visa')) {
      imagePath = 'lib/assets/Visa.png';
    } else if (img.contains('Master')) {
      imagePath = 'lib/assets/Master.png';
    } else {
      imagePath = 'assets/images/Logo.png'; // Fallback image
    }

    return InkWell(
      onTap: () {
        print('Button Pressed');
        print(paymentData);
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => PaymentInfoDetails(type: type, existingPayment: paymentData,)
          )
        );
      },
      splashColor: Colors.grey.withOpacity(0.3),  // Set the splash color for the ripple effect
      highlightColor: Colors.grey.withOpacity(0.2),  // Set the highlight color
      borderRadius: BorderRadius.circular(8),  // Optional: to round the corners of the button
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image(
              image: AssetImage(imagePath),
              width: 60,
              height: 60,
            ),
            const SizedBox(width: 10,),
        
            Text(label,
              style: const TextStyle(
                fontSize: 16
              ),
            ),
        
            const Spacer(),
        
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    if(isExist){
                      bool? confirmed = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Removal'),
                            content: const Text('Are you sure you want to remove this payment method?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false); // Cancel
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true); // Confirm
                                },
                                child: const Text('Remove'),
                              ),
                            ],
                          );
                        },
                      );

                      if(confirmed == true && documentId != null){
                        try {
                          final firestore = FirebaseFirestore.instance;
                          await firestore.collection('Payment').doc(documentId).delete();
                          print('Deleted payment method: $documentId');

                          // Refresh the list
                          setState(() {
                            currentPayments.removeWhere((payment) => payment['id'] == documentId);
                          });
                        } catch (e) {
                          print('Error removing payment method: $e');
                        }
                      }
                    }else{
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => PaymentInfoDetails(type: type, existingPayment: paymentData,)
                        )
                      );
                    }
                  }, 
                  icon: isExist ? const Icon(Icons.remove) : const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}