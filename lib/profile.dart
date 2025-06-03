import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'about.dart';
import 'editPassword.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userInfo = {};
  String username = '';
  String phoneNum = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("Current User: ${FirebaseAuth.instance.currentUser}");
    if (FirebaseAuth.instance.currentUser != null) {
      fetchUserInfo();
    } else {
      print("No user is logged in.");
    }
  }

  Future<void> fetchUserInfo() async{
    try{
      String id = FirebaseAuth.instance.currentUser!.uid;
      print('User ID: $id');

      DocumentSnapshot docRef = await FirebaseFirestore.instance
        .collection('User')
        .doc(id)
        .get();

      print('Docref: ${docRef.data()}');

      if(docRef.exists){
        print("Document fetched: ${docRef.data()}");
        setState(() {
          userInfo = docRef.data() as Map<String, dynamic>;
          username = userInfo['username'];
          phoneNum = userInfo['phoneNumber'];
        });
        print(userInfo);
      }

    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  Future<void> _updateUsernameInFirestore(String newValue) async {
    try {
      // Get the current user ID from FirebaseAuth
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (userId.isNotEmpty) {
        // Update Firestore document for the current user
        await FirebaseFirestore.instance.collection('User').doc(userId).update({
          'username': newValue,  // Update the username field
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating phone number: $e')),
      );
    }
  }

  Future<void> _updatePhoneNumberInFirestore(String newPhoneNumber) async {
    try {
      // Remove hyphen from the phone number
      newPhoneNumber = newPhoneNumber.replaceAll('-', '');

      if(newPhoneNumber.length < 10 || newPhoneNumber.length > 11){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid phone number')),
        );
        return;
      }
  
      // Get the current user ID from FirebaseAuth
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  
      if (userId.isNotEmpty) {
        // Update Firestore document for the current user
        await FirebaseFirestore.instance.collection('User').doc(userId).update({
          'phoneNumber': newPhoneNumber,  // Update the phone number field without hyphens
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number updated successfully.')),
        );
      }
    } catch (e) {
      if(newPhoneNumber.length < 10 || newPhoneNumber.length > 11){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating phone number: $e')),
        );
      }
    }
  }


  // Function to open the dialog to edit username
  void _openEditDialog(String field, String currentValue) {
    _controller.text = currentValue;  // Pre-fill the text field with current username

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter new $field',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                String newValue = _controller.text.trim();

                if (newValue.isNotEmpty) {
                  if(field.contains('Phone')){
                    if(newValue.length < 10 || newValue.length > 11){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid phone number')),
                      );
                      return;
                    }
                    await _updatePhoneNumberInFirestore(newValue);
                    setState(() {
                      phoneNum = newValue;
                    });
                  }else{
                    await _updateUsernameInFirestore(newValue);
                    setState(() {
                      username = newValue;
                    });
                  }
                }

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  String formatPhoneNumber(String phoneNumber) {
  // Remove non-numeric characters
  phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), ''); // Remove non-digit characters

  // Check if phone number has 10 or 11 digits
  if (phoneNumber.length == 10 || phoneNumber.length == 11) {
    // Format as 000-0000000
    return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 6)}${phoneNumber.substring(6)}';
  } 

  return phoneNumber; // Return unformatted if not 10 or 11 digits
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD9D9D9),
                  
                ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(
                      Icons.person,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          IconButton(
                            onPressed: (){
                              _openEditDialog('Username', username);
                            }, 
                            icon: const Icon(Icons.edit),
                            iconSize: 20,
                          )
                        ],
                      ),
                      Text(
                        FirebaseAuth.instance.currentUser!.email!,
                        style: const TextStyle(
                          fontSize: 16.0,
                          //color: Colors.grey[600],
                        ),
                      ),

                      Row(
                        children: [
                          Text(
                            formatPhoneNumber(phoneNum),
                            style: const TextStyle(
                              fontSize: 16.0,
                              //fontWeight: FontWeight.bold,
                            ),
                          ),

                          IconButton(
                            onPressed: (){
                              _openEditDialog('Phone Number', phoneNum);
                            }, 
                            icon: const Icon(Icons.edit),
                            iconSize: 16,
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),
            ListTile(
              leading: const Icon(Icons.password, color: Colors.black),
              title: const Text('Change Password'),
              onTap: () {
                // Handle edit profile
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const EditPassword()
                  )
                );
              },
            ),
            const Divider(),
            // ListTile(
            //   leading: const Icon(Icons.credit_card, color: Colors.black),
            //   title: const Text('Payment information'),
            //   onTap: () {
            //     // Handle payment information
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const PaymentDetails()
            //       )
            //     );
            //   },
            // ),
            // const Divider(),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.black),
              title: const Text('About'),
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const AboutPage()
                  )
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text('Log out'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Log out'),
                      content: const Text('Do you really want to log out?'),
                      actions: [
                        // No button - just close the dialog
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text('No'),
                        ),
                        // Yes button - log out and navigate to login page
                        TextButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut(); // Log out
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

