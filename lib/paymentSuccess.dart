import 'package:flutter/material.dart';
import 'button.dart';
import 'home.dart';

class PaymentSuccess extends StatelessWidget{
  final num? totalAmount;

  const PaymentSuccess({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.paid_outlined,
              size: 100,
            ),
            const SizedBox(height: 40,),
            Text('RM ${totalAmount!.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 60,),
            const Text('Payment Successful!',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 20,),
            const Text('Your order is placed. \nPlease pick up at the counter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 250,),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home()
                  )
                );
              },
              style: roundedButton,
              child: const Text('Done',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white
                ),
              )
              ),
          ],
        ),
      ),
    );
  }
}