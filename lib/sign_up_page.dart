import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_page.dart';
import 'FirebaseAuthImplementation/firebaseAuthServices.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final Firebaseauthservices _auth = Firebaseauthservices();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override 
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
            Center(child: Image.asset('lib/assets/logo.png', height: 120)),
            const SizedBox(height: 20),
            const Text('Sign up', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            // Name Field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Name',
                //suffixIcon: const Icon(Icons.check, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            // Email Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            // Phone Number Field
            TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11)
              ],
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            // Password Field
            TextField(
              obscureText: true,
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 30),
            // Sign Up Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC59D54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: signUp,
                child: const Text('Sign up', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              ),
              child: const Text.rich(
                TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(color: Colors.black54),
                  children: [
                    TextSpan(text: "Login now!", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signUp() async{
    String username = _usernameController.text;
    String email = _emailController.text;
    String phoneNumber = _phoneNumberController.text;
    String password = _passwordController.text;

    if(email.isEmpty || password.isEmpty || phoneNumber.isEmpty || password.isEmpty){
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Register Failed"),
            content: const Text("Please enter the required information."),
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

    User? user = await _auth.signUpWithEmailAndPassword(email, password, context);

    if(user?.uid != null){
      final batch = FirebaseFirestore.instance.batch();
      final addUser = FirebaseFirestore.instance.collection('User').doc(user!.uid);
      batch.set(addUser, {
        'uid': user.uid,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber
      });

      await batch.commit();

      print("User successfully created");
      showDialog(
        context: context, 
        builder: (context){
          return AlertDialog(
            title: const Text('Sign Up Successfully'),
            content: const Text('The account has successfully registered. Try login now!'),
            actions: [
              TextButton(
                onPressed: (){
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
}
