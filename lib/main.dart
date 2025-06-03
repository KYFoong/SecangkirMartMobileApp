import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51Qf2x8Rr69N5fVT67Q1PgDRxHlvPnFMK7o5E3FUpoivD6f7Nudw6ZKFfdint0VuLBFxTnwRwNu6ZevXO0Fw6V6SW00IES9whUJ';
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secangkir Cafe App',
      theme: ThemeData(primaryColor: const Color(0xFFC59D54)),
      home: const LoginPage(),
    );
  }
}
