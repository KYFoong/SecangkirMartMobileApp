import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'button.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({super.key});

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Function to re-authenticate user
  Future<UserCredential?> _reauthenticateUser(String password) async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is logged in.')),
      );
      return null;
    }

    try {
      // Re-authenticate user with their current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      return await user.reauthenticateWithCredential(credential);
    } catch (e) {
      print('Re-authentication failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Re-authentication failed.')),
      );
      return null;
    }
  }

  // Function to change the password
  Future<void> _changePassword() async {
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Check if the new password is the same as the old one
    if (oldPassword == newPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password cannot be the same as old password.')),
      );
      return;
    }else if(newPassword != confirmPassword){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your password is not the same.')),
      );
      return;
    }

    // Re-authenticate user before allowing password change
    UserCredential? userCredential = await _reauthenticateUser(oldPassword);

    if (userCredential != null) {
      try {
        // Update password
        await _auth.currentUser?.updatePassword(newPassword);
        _showSuccessDialog();
      } catch (e) {
        print('Password change failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password change failed.')),
        );
      }
    }
  }

  // Function to show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Your password has been changed successfully.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pop(context); // Go back to the profile page
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password', 
          style: TextStyle(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text('Current Password',
              style: boldText(),
            ),

            TextField(
              obscureText: true,
              controller: _oldPasswordController,
              decoration: InputDecoration(
                hintText: 'Old password',
                hintStyle: const TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 20,),

            Text('New Password',
              style: boldText(),
            ),

            TextField(
              obscureText: true,
              controller: _newPasswordController,
              decoration: InputDecoration(
                hintText: 'New password',
                hintStyle: const TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 20,),

            Text('Confirm New Password',
              style: boldText(),
            ),

            TextField(
              obscureText: true,
              controller: _confirmPasswordController,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                hintText: 'Confirm new password',
                hintStyle: const TextStyle(color: Color.fromARGB(100, 0, 0, 0)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      _changePassword();
                    }, 
                    style: roundedButton,
                    child: Text('Confirm',
                      style: boldText().copyWith(color: Colors.white),
                    )
                  ),

                  const SizedBox(height: 120,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  TextStyle boldText(){
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18
    );
  }
}