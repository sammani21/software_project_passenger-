import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

// ignore: use_key_in_widget_constructors
class ForgotPassword extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _handleSubmit() async {
    String email = _emailController.text;

    if (email.isEmpty) {
      _showDialog('Error', 'Please enter your email address.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

  try{
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/v1/passenger/fpassword'),
      
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      
        _showDialog('Password Reset', 'Check your email for password reset link.', popTwice: true);
    } 
      else {
        _showDialog('Error', 'Something went wrong. Please try again.');
    }
    
  }catch(error){
    setState(() {
      _isLoading = false;
    });
    _showDialog('Error', 'Something went wrong. Please try again.');
  }
  }

  void _showDialog(String title, String message, {bool popTwice = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (popTwice) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK'),
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
        title: const Text('Forgot Password'),
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFFB39DDB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /*Center(
                      child: Image.asset(
                        'assets/logo.jpg',
                        height: 150,
                        width: 150,
                      ),
                    ),*/
                    Center(
              child: Lottie.asset(
                'assets/forgot_password_animation.json', // Path to your Lottie animation asset
                height: 300, // Adjust the height as needed
                width: 300,  // Adjust the width as needed
              ),
            ),
                    const SizedBox(height: 20.0),
                    const Center(
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Center(
                      child: Text(
                        'Password reset option',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.email, color: Color(0xFF6C63FF)),
                      ),
                      style: const TextStyle(fontSize: 18.0),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20.0),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                padding: const EdgeInsets.symmetric(vertical: 15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5.0,
                                shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
                              ),
                              child: const Text(
                                'SUBMIT',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
