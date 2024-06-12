import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie package

class GetEmailScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  GetEmailScreen({super.key});

  Future<String?> _getStoredEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('passenger');
    
    if (userJson != null) {
      final data = jsonDecode(userJson);
      return data['email'];
    }
    return null;
  }

  void _handleSubmit(BuildContext context) async {
    final enteredEmail = _emailController.text;
    final storedEmail = await _getStoredEmail();

    if (enteredEmail == storedEmail) {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/updatePassenger', arguments: enteredEmail);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entered email does not match the stored email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Enter Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add the Lottie animation here
            Center(
              child: Lottie.asset(
                'assets/email_animation.json', // Path to your Lottie animation asset
                height: 400, // Adjust the height as needed
                width: 400,  // Adjust the width as needed
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter your email to update your details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _handleSubmit(context),
                // ignore: sort_child_properties_last
                child: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
