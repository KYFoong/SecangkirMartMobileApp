import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'button.dart';
import 'paymentInfo.dart';

class TouchNGOUI extends StatefulWidget {
  final Map<String, dynamic>? existingPayment;
  //final TextEditingController nameController;
  //final TextEditingController phoneNumberController;

  const TouchNGOUI({super.key,
    this.existingPayment
    //required this.nameController,
    //required this.phoneNumberController,
  });

  @override
  State<TouchNGOUI> createState() => _TouchNGOUIState();
}

class _TouchNGOUIState extends State<TouchNGOUI> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.existingPayment != null) {
      // If editing, populate fields with existing data
      nameController.text = widget.existingPayment!['name'];
      phoneNumberController.text = widget.existingPayment!['phoneNumber'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Image(
              image: AssetImage('assets/images/TnG.png'),
              width: 60,
              height: 60,
            ),

            const SizedBox(width: 10,),

            Text('Touch n Go',
              style: boldText(),
            ),
          ],
        ),

        const SizedBox(height: 20,),

        Text('Name', style: boldText(),),
        const SizedBox(height: 10,),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Full Name',
            hintStyle: const TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        const SizedBox(height: 10,),

        Text('Phone Number', style: boldText(),),
        const SizedBox(height: 10,),
        TextField(
          controller: phoneNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: InputDecoration(
            hintText: 'Phone Number',
            hintStyle: const TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        const SizedBox(height: 80,),

        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: savePaymentTNG,
                style: roundedButton, 
                child: const Text('Confirm',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle boldText(){
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20
    );
  }

  Future<void> savePaymentTNG() async{
    String name = nameController.text;
    String phoneNumber = phoneNumberController.text;

    if(name.isEmpty || phoneNumber.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields with valid information.')),
      );
      return;
    }

    if(phoneNumber.length < 10 && phoneNumber.length > 11){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }

    final db = FirebaseFirestore.instance;

    try{
      if(widget.existingPayment == null){
        await db.collection('Payment').add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'type': 'Touch n Go',
          'name': name,
          'phoneNumber': phoneNumber,
        });
        showDialog(
          context: context, 
          builder: (context){
            return AlertDialog(
              title: const Text('Payment Method Saved'),
              content: const Text('Payment information saved successfully!'),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PaymentDetails()));
                  },
                  child: const Text('OK')
                )
              ],
            );
          }
        );
      }else{
        await db.collection('Payment').doc(widget.existingPayment!['id']).update({
          'name': name,
          'phoneNumber': phoneNumber,
        });
        showDialog(
          context: context, 
          builder: (context){
            return AlertDialog(
              title: const Text('Payment Method Updated'),
              content: const Text('Payment information updated successfully!'),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PaymentDetails()));
                  },
                  child: const Text('OK')
                )
              ],
            );
          }
        );
      }
      
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving payment information: $e')),
      );
    }
  }
}
