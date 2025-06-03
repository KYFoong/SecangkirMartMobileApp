import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'button.dart';
import 'paymentInfo.dart';

class CardPaymentUI extends StatefulWidget {
  final String type;
  final Map<String, dynamic>? existingPayment;
  //final TextEditingController nameController;
  //final TextEditingController cardNumberController;
  //final TextEditingController monthController;
  //final TextEditingController yearController;
  //final TextEditingController cvvController;

  const CardPaymentUI({super.key, 
    required this.type,
    this.existingPayment
    //required this.nameController,
    //required this.cardNumberController,
    //required this.monthController,
    //required this.yearController,
    //required this.cvvController,
  });

  @override
  State<CardPaymentUI> createState() => _CardPaymentUIState();
}

class _CardPaymentUIState extends State<CardPaymentUI> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  late final String imagePath;

  @override
  void initState() {
    super.initState();

    if (widget.existingPayment != null) {
      // If editing, populate fields with existing data
      nameController.text = widget.existingPayment!['name'];
      cardNumberController.text = widget.existingPayment!['cardNum'];
      monthController.text = widget.existingPayment!['month'].toString();
      yearController.text = widget.existingPayment!['year'].toString();
      cvvController.text = widget.existingPayment!['cvv'].toString();
    }

    if (widget.type.contains('Visa')) {
      imagePath = 'lib/assets/Visa.png';
    } else if (widget.type.contains('Master')) {
      imagePath = 'lib/assetsMaster.png';
    } else {
      imagePath = 'assets/images/Logo.png'; // Fallback image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image(
              image: AssetImage(imagePath),
              width: 60,
              height: 60,
            ),

            const SizedBox(width: 10,),

            Text(
              widget.type,
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

        Text('Card Number', style: boldText(),),
        const SizedBox(height: 10,),
        TextField(
          controller: cardNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CardNumberInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: '0000-0000-0000-0000',
            hintStyle: const TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        const SizedBox(height: 10,),

        Row(
          children: [
            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expiry Date', style: boldText(),),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: monthController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            hintText: 'MM',
                            hintStyle: const TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      Text(' / ', style: boldText(),),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: yearController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            hintText: 'YY',
                            hintStyle: const TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),
            const SizedBox(width: 10), 

            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CVV', style: boldText(),),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: cvvController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      hintText: '000',
                      hintStyle: const TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 80,),

        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: savePaymentInfo,
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

  Future<void> savePaymentInfo() async {
    String name = nameController.text; // Replace with TextField controller values
    String cardNumber = cardNumberController.text.replaceAll('-', '').trim();
    int? month = int.tryParse(monthController.text.trim());
    int? year = int.tryParse(yearController.text.trim());
    int? cvv = int.tryParse(cvvController.text.trim());

    DateTime now = DateTime.now();
    int currentYear = int.parse(now.year.toString().substring(2)); // Get last two digits of the year
    int currentMonth = now.month;

    // Validate the input values
    if (name.isEmpty || cardNumber.isEmpty || month == null || year == null || cvv == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields with valid information.')),
      );
      return;
    }

    if (cardNumber.length != 16) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card number must be 16 digits.')),
    );
    return;
  }

  if (month < 1 || month > 12) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Month must be between 1 and 12.')),
    );
    return;
  }

  if (year < currentYear || (year == currentYear && month < currentMonth)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card is invalid or expired.')),
    );
    return;
  }

  if (cvv.toString().length != 3) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CVV must be 3 digits.')),
    );
    return;
  }

    final db = FirebaseFirestore.instance;

    try{
      if (widget.existingPayment == null) {
        // Add new payment info
        await db.collection('Payment').add({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'type': widget.type,
          'name': name,
          'cardNum': cardNumber,
          'month': month,
          'year': year,
          'cvv': cvv,
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
      } else {
        // Update existing payment info
        await db.collection('Payment').doc(widget.existingPayment!['id']).update({
          'name': name,
          'cardNum': cardNumber,
          'month': month,
          'year': year,
          'cvv': cvv,
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

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('-', '');
    String formattedText = '';

    for (int i = 0; i < text.length; i++) {
      if (i % 4 == 0 && i != 0) {
        formattedText += '-';
      }
      formattedText += text[i];
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

