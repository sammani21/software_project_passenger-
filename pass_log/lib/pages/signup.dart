import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nicNoController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _serviceNoController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();


  DateTime? _selectedBirthday;
  bool _showPassword = false;
  String? _errorMessage;
  String _passwordStrength = "";
  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female' , 'Other'];
   bool _isInternal = false;

  bool _isStrongPassword(String password) {
    final uppercaseRegex = RegExp(r'[A-Z]');
    final lowercaseRegex = RegExp(r'[a-z]');
    final numberRegex = RegExp(r'[0-9]');
    final specialCharacterRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    return password.length >= 8 &&
        uppercaseRegex.hasMatch(password) &&
        lowercaseRegex.hasMatch(password) &&
        numberRegex.hasMatch(password) &&
        specialCharacterRegex.hasMatch(password);
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
    double strengthValue;

    if (strength == "Password cannot be empty" || strength == "Password too short") {
      color = Colors.red;
      text = "Weak";
      strengthValue = 0.2;
    } else if (strength.contains("must contain")) {
      color = Colors.orange;
      text = "Medium";
      strengthValue = 0.5;
    } else if (strength == "Strong") {
      color = Colors.green;
      text = "Strong";
      strengthValue = 1.0;
    } else {
      color = Colors.red;
      text = "Weak";
      strengthValue = 0.2;
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
            value: strengthValue,
            color: color,
            backgroundColor: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Future _handleSubmit() async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final nicNo = _nicNoController.text;
    final birthday = _birthdayController.text;
    final gender = _selectedGender;
    final contactNo = _contactNoController.text;
    final serviceNo = _serviceNoController.text;
    final isInternal = _isInternal;
    final companyName = _companyNameController.text;
   
    if (gender == null) {
      setState(() {
        _errorMessage = "Please select a gender";
      });
      return;
    }

    if (!_isStrongPassword(password)) {
      setState(() {
        _errorMessage =
            "Password should contain at least 8 characters, including uppercase letters, lowercase letters, numbers, and special characters";
      });
      return;
    }

     if (isInternal && companyName.isEmpty) {
      setState(() {
        _errorMessage = "Company Name is required for internal users";
      });
      return;
    }

    final response = await http.post(
      Uri.parse("http://localhost:3000/api/v1/passenger/signup"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'nicNo': nicNo, // '123456789V' is a placeholder for 'nicNo
        'username': username,
        'email': email,
        'password': password,
        'gender': gender,
        'birthday': birthday,
        'contactNo': contactNo,
        'serviceNo': serviceNo,
        'isInternal': isInternal,
        'companyName': companyName,
      }),
    );

    if (response.statusCode == 201) {
      //final data = jsonDecode(response.body);
      //if (data['status']) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created the account successfully')),
        );
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/login');
    } else if (response.statusCode == 400) {

      setState(() {
    _errorMessage = 'User already exists';
  });
  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('User already exists')),
  );
      } else {
      setState(() {
        //_errorMessage = 'User already exists';
        _errorMessage = 'an error occured, please try again later.';
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('an error occured, please try again later.')),
        );
     }
    } 

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
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
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      /*Center(
                        child: Image.asset(
                          'assets/logo.jpg',
                          height: 200,
                          width: 200,
                        ),
                      ),*/
                       Center(
              child: Lottie.asset(
                'assets/signup_animation.json', // Path to your Lottie animation asset
                height: 300, // Adjust the height as needed
                width: 300,  // Adjust the width as needed
              ),
            ),
                      const SizedBox(height: 15.0),
                      const Center(
                        child: Text(
                          'Create an Account',
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
                        'Please Register to continue',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
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
                      const SizedBox(height: 18.0),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
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
                      TextFormField(
                        controller: _nicNoController,
                        decoration: InputDecoration(
                          labelText: 'National Identity Card Number',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF6C63FF)),
                        ),
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      const SizedBox(height: 10.0),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        items: _genderOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)),
                        ),
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _birthdayController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: 'Birthday',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6C63FF)),
                        ),
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      const SizedBox(height: 18.0),
                      TextFormField(
                        controller: _contactNoController,
                        decoration: InputDecoration(
                          labelText: 'Contact No',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.phone, color: Color(0xFF6C63FF)),
                        ),
                        style: const TextStyle(fontSize: 18.0),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'Internal User',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Checkbox(
                            value: _isInternal,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _isInternal = newValue ?? false;
                              });
                            },
                          ),
                          const Text(
                            '(Tick if you are an internal user)',
                            style: TextStyle(fontSize: 18.0, color: Colors.red),
                            ),
                        ],
                      ),
                      if (_isInternal) ...[
                        TextFormField(
                          controller: _companyNameController,
                          decoration: InputDecoration(
                            labelText: 'Company Name',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.business, color: Color(0xFF6C63FF)),
                          ),
                          style: const TextStyle(fontSize: 18.0),
                        ),
                        const SizedBox(height: 18.0),
                        TextFormField(
                          controller: _serviceNoController,
                          decoration: InputDecoration(
                            labelText: 'Service No',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.badge, color: Color(0xFF6C63FF)),
                          ),
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ],
                      const SizedBox(height: 10.0),
                      TextFormField(
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
                      TextFormField(
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
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
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
                            icon: Icon(
                              _showPassword ? Icons.visibility : Icons.visibility_off,
                            ),
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
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
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
                            'SIGN UP',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                    const Center(child: Text('Have an account?')),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          'Login',
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
      ),
    );
  }
}
