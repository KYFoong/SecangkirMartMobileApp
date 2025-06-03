import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cardDetailsUI.dart';
import 'touchNGoUI.dart';

class PaymentInfoDetails extends StatefulWidget {
  final String type;
  final Map<String, dynamic>? existingPayment;

  const PaymentInfoDetails({super.key, required this.type, this.existingPayment});

  @override
  State<PaymentInfoDetails> createState() => _PaymentInfoDetailsState();
}

class _PaymentInfoDetailsState extends State<PaymentInfoDetails> {
  //final TextEditingController _name = TextEditingController();
  //final TextEditingController _cardNum = TextEditingController();
  //final TextEditingController _month = TextEditingController();
  //final TextEditingController _year = TextEditingController();
  //final TextEditingController _cvv = TextEditingController();
  late final String imagePath;

/*
  @override
  void initState() {
    super.initState();

    if (widget.existingPayment != null) {
      // If editing, populate fields with existing data
      _name.text = widget.existingPayment!['name'];
      _cardNum.text = widget.existingPayment!['cardNum'];
      _month.text = widget.existingPayment!['month'].toString();
      _year.text = widget.existingPayment!['year'].toString();
      _cvv.text = widget.existingPayment!['cvv'].toString();
    }

    if (widget.type.contains('Touch n Go')) {
      imagePath = 'assets/images/TnG.png';
    } else if (widget.type.contains('Visa')) {
      imagePath = 'assets/images/Visa.png';
    } else if (widget.type.contains('Master')) {
      imagePath = 'assets/images/Master.png';
    } else {
      imagePath = 'assets/images/Logo.png'; // Fallback image
    }
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingPayment == null ? 'Add Payment Information' : 'Edit Payment Information', 
          style: const TextStyle(
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
        child: (widget.type.contains('Card')) ? 
          CardPaymentUI(type: widget.type, existingPayment: widget.existingPayment,) : 
          TouchNGOUI(existingPayment: widget.existingPayment,)
        /*Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Title
            Row(
              children: [
                Image(
                  image: AssetImage(imagePath),
                  width: 60,
                  height: 60,
                ),
        
                const SizedBox(width: 10,),
        
                Text(widget.type,
                  style: boldText()
                ),
              ],
            ),

            const SizedBox(height: 20,),

            Text('Name', style: boldText(),),
            const SizedBox(height: 10,),
            TextField(
              controller: _name,
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
              controller: _cardNum,
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
                Expanded( // This will help avoid layout overflow
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
                              controller: _month,
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
                              controller: _year,
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

                const SizedBox(width: 10), // Provide spacing between the columns

                Expanded( // Ensures both columns take equal space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CVV', style: boldText(),),
                      const SizedBox(height: 10,),
                      TextField(
                        controller: _cvv,
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
        ),*/
      ),
    );
  }

  TextStyle boldText(){
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20
    );
  }
/*
  Future<void> savePaymentInfo() async {
    String name = _name.text; // Replace with TextField controller values
    String cardNumber = _cardNum.text.replaceAll('-', '').trim();
    int? month = int.tryParse(_month.text.trim());
    int? year = int.tryParse(_year.text.trim());
    int? cvv = int.tryParse(_cvv.text.trim());

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment information saved successfully!')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment information updated successfully!')),
        );
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving payment information: $e')),
      );
    }
  }*/
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
