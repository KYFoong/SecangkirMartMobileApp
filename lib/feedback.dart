import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'button.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FeedbackForm(),
    );
  }
}

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Feedback',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Write a feedback',
                border: OutlineInputBorder(),
                alignLabelWithHint: true
              ),
              maxLines: 15,
              onSaved: (value) => _feedbackController.text = value!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your feedback';
                }
                return null;
              },
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: roundedButton,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                  
                          await submitFeedback(
                            feedback: _feedbackController.text
                          );

                          setState(() {
                            _feedbackController.clear();
                          });

                          

                          // Process the feedback (e.g., send to server or save locally)
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Thank you!'),
                              content: const Text('Your feedback has been submitted.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Submit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> submitFeedback({
  required String feedback,
}) async {
  try {
    final batch = FirebaseFirestore.instance.batch();
    final userID = FirebaseAuth.instance.currentUser!.uid;
    
    final userDoc = await FirebaseFirestore.instance.collection('User').doc(userID).get();
    final username = userDoc['username'];
    final email = userDoc['email'];
    final phoneNumber = userDoc['phoneNumber'];

    // Create new order document
    final orderRef = FirebaseFirestore.instance.collection('Feedback').doc();
    batch.set(orderRef, {
      'userID': userID,
      'name': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'feedback': feedback
    });

    // Commit the batch
    await batch.commit();
  } catch (e) {
    // Handle error
    debugPrint('Error submitting feedback: $e');
    rethrow; // Rethrow to handle in UI
  }
}