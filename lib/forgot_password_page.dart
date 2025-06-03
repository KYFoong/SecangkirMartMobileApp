import 'package:flutter/material.dart';
import 'FirebaseAuthImplementation/firebaseAuthServices.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final Firebaseauthservices _auth = Firebaseauthservices();

  final TextEditingController _emailController = TextEditingController();

  @override 
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(child: Image.asset('lib/assets/logo.png', height: 120)),
            const SizedBox(height: 20),
            const Text('Request Email', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            // Email Field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
            // Request Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC59D54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: resetPassword,
                child: const Text('Request', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void resetPassword() async{
    String email = _emailController.text;

    if(email.isEmpty){
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Request Failed"),
            content: const Text("Please enter the email"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!emailRegex.hasMatch(email)) {
      // Show an error dialog for invalid email format
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Invalid Email'),
            content: const Text('Please enter a valid email address.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the function if the email is invalid
    }

    await _auth.sendPasswordResetLink(email);
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Email Sent'),
          content: const Text('Check your email for the reset password application form.'),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: 
                  (context) => const LoginPage()
                ));
              }, 
              child: const Text('OK')
            )
          ],
        );
      }
    );
  }
}
