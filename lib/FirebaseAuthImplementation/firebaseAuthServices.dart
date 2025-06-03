import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Firebaseauthservices {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password, BuildContext context) async{

    try{
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch(e){
      String errorMessage;

      if (e is FirebaseAuthException) {
        // Map Firebase error codes to user-friendly messages
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'The email address is already in use by another account.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          case 'weak-password':
            errorMessage = 'The password is too weak.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password accounts are not enabled.';
            break;
          default:
            errorMessage = 'An unexpected error occurred. Please try again later.';
        }
      } else {
        // Fallback for other types of exceptions
        errorMessage = 'An error occurred. Please try again.';
      }

      showDialog(
        context: context, 
        builder: (context){
          return AlertDialog(
            title: const Text('Sign Up Failed'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                }, 
                child: const Text('OK')
              )
            ],
          );
        }
      );
    }

    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async{

    try{
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch(e){
      print("Some error occur");
    }

    return null;
  }

  Future<void> sendPasswordResetLink(String email) async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
    }catch(e){
      print((e).toString());
    }
  }
}