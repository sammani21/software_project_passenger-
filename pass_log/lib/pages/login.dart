import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'network_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required String title});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  String _errorMessage = "";
  String _passwordStrength = "";

  

 Future<void> _handleSubmit() async {
  final username = _usernameController.text;
  final password = _passwordController.text;

  if (username.isEmpty || password.isEmpty) {
    setState(() {
      _errorMessage = "Please fill in both fields.";
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = "";
  });

  try {
    final response = await http.post(
      Uri.parse("http://localhost:3000/api/v1/passenger/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {//204 kiwwama content ekak na eka 200 karala balana 
        // ignore: avoid_print
        //print('response body: ${response.body}');

        final responseData = jsonDecode(response.body);
        if (kDebugMode) {
          print(responseData);
        }

        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        await prefs.setString('token', responseData['token']);

        await prefs.setString('passenger', jsonEncode(responseData['data']));
       
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User logged in successfully')),
        );
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/dashboard');
        _usernameController.clear();
        _passwordController.clear();
     
    } else if (response.statusCode == 400) {
      setState(() {
        _errorMessage = 'User not registered. Please sign up.';
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not registered. Please sign up.')),
      );
    } else if (response.statusCode == 401) {
      setState(() {
        _errorMessage = 'Invalid password.';
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid password.')),
      );
    }
    else {
      setState(() {
        _errorMessage = 'An error occurred, please try again later.';
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred, please try again later.')),
      );
    }
  } catch (error) {
    setState(() {
      _isLoading = false;
      _errorMessage = "Failed to login. Please try again.";
    });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to login. Please try again.')),
    );
  }
}


  String _validatePassword(String password) {
    if (password.isEmpty) {
      return "Password cannot be empty";
    } else if (password.length < 8) {
      return "Password too short";
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Password must contain an uppercase letter";
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "Password must contain a lowercase letter";
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "Password must contain a number";
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return "Password must contain a special character";
    } else {
      return "Strong";
    }
  }

  Widget _buildPasswordStrengthMeter(String strength) {
    Color color;
    String text;
    if (strength == "Password too short" || strength == "Password cannot be empty") {
      color = Colors.red;
      text = "Weak";
    } else if (strength.contains("must contain")) {
      color = Colors.orange;
      text = "Medium";
    } else if (strength == "Strong") {
      color = Colors.green;
      text = "Strong";
    } else {
      color = Colors.red;
      text = "Weak";
    }

    return Row(
      children: [
        Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LinearProgressIndicator(
            value: strength == "Strong"
                ? 1.0
                : (strength == "Medium" ? 0.5 : 0.2),
            color: color,
            backgroundColor: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*Center(
                      child: Image.asset(
                        'assets/logo.jpg',
                        height: 200,
                        width: 200,
                      ),
                    ),*/
                     const SizedBox(height: 10.0), // Reduced gap
                    Center(
              child: Lottie.asset(
                'assets/login_animation.json', // Path to your Lottie animation asset
                height: 400, // Adjust the height as needed
                width: 400,  // Adjust the width as needed
              ),
            ),
                    const SizedBox(height: 5.0),
                    const Center(
                      child: Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Center(
                      child: Text(
                        'Please login to your account',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF6C63FF)),
                      ),
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 10.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      onChanged: (password) {
                        setState(() {
                          _passwordStrength = _validatePassword(password);
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFF6C63FF)),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 10.0),
                    _buildPasswordStrengthMeter(_passwordStrength),
                    const SizedBox(height: 10.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/fpassword');
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    if (_errorMessage.isNotEmpty)
                      Center(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF), // Button color
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5.0,
                          shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Center(child: Text('Don\'t have an account?')),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.blue),
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
