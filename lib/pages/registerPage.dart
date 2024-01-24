import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:recipes_app/pages/homePage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  void _register() async {
    try {
      String username = _usernameController.text;
      String password = _passwordController.text;
      String confirmPassword = _confirmPasswordController.text;

      // Check if password and confirm password are the same
      if (password != confirmPassword) {
        showDialog(
          context: context, // Pass the current context
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Register Failed'), // Set the title of the dialog
              content: Text('Password do not match!'), // Set the content of the dialog
              actions: [
                // Add buttons or other actions
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: '$username@utem.my', // Use a dummy email
        password: password,
      );


      // Add user information to Firestore
      await _firestore.collection('Users').doc('$username@utem.my').set({
        'Display Name': username,
        'Username': username,
        // Add other user data as needed
      });

      // Successful registration
      print("Registration Success");

      // Navigate to the home page or perform other actions
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (error) {
      // Failed registration
      showDialog(
        context: context, // Pass the current context
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Register Failed'), // Set the title of the dialog
            content: Text('Registration failed: $error'), // Set the content of the dialog
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.purple[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          Text("Create your username thoughtfully, as it cannot be changed.", style: TextStyle(fontSize: 12,color: Colors.red),),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_person_rounded),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 110.0, vertical: 10.0),
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
