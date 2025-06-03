import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'orderDetails.dart';

class CompletedOrdersPage extends StatefulWidget {
  const CompletedOrdersPage({super.key});

  @override
  _CompletedOrdersPageState createState() => _CompletedOrdersPageState();
}

class _CompletedOrdersPageState extends State<CompletedOrdersPage> {
  String currentStatus = 'Processing';


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        currentStatus = 'Processing';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(165, 45),
                      backgroundColor: currentStatus == 'Processing' 
                        ? const Color(0xFFC59D54) // Gold color when Processing
                        : Colors.grey, // Grey color if other status
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Assuming rectangleRoundCorner had rounded corners
                      ),
                    ),
                    child: const Text(
                      'Processing',
                      textAlign: TextAlign.center,
                      style: orderStatusButton,
                    ),
                  ),
              
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        currentStatus = 'Completed';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(165, 45),
                      backgroundColor: currentStatus == 'Completed' 
                        ? const Color(0xFFC59D54) // Gold color when Processing
                        : Colors.grey, // Grey color if other status
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Assuming rectangleRoundCorner had rounded corners
                      ),
                    ), 
                    child: const Text(
                      'Completed',
                      textAlign: TextAlign.center,
                      style: orderStatusButton,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Order')
                    .where('orderStatus', isEqualTo: currentStatus)
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .orderBy('orderCode', descending: true)
                    .orderBy(FieldPath.documentId, descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('No ${currentStatus.toLowerCase()} orders'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final order = snapshot.data!.docs[index];
                      return OrderCard(order: order);
                    },
                  );
                }
              )
            )
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final data = order.data() as Map<String, dynamic>;
    final orderNumber = 'ON${data['orderCode'].toString().padLeft(4, '0')}' ?? 'ON000';
    final orderDate = (data['placedOn'] as Timestamp).toDate();
    final quantity = data['totalProducts'] ?? 0;
    final totalAmount = data['totalPrice'] ?? 0.0;
    final status = data['orderStatus'] ?? 'Processing';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order number: $orderNumber',
                  style: orderCardText
                ),
                Text(
                  '${orderDate.day}/${orderDate.month}/${orderDate.year}',
                  style: orderCardText,
                ),
              ],
            ),
            
            Text('Quantity: $quantity',
              style: orderCardText,
            ),
            const SizedBox(height: 8),
            // Details button and status with total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC59D54),
                  ),
                  onPressed: () {
                    print(order.id);
                    Navigator.push(context, 
                      MaterialPageRoute(builder: (context) => Orderdetails(orderId: order.id))
                    );
                  },
                  child: const Text(
                    'Details',
                    style: orderStatusButton,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        color: status == 'Processing'
                            ? const Color.fromARGB(255, 194, 5, 5) // Red color for Pending
                            : const Color.fromARGB(255, 5, 194, 5), // Green color for Completed
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      ),
                    ),
                    Text('Total amount: RM ${totalAmount.toStringAsFixed(2)}',
                      style: orderCardText,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}