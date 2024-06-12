import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePassengerScreen extends StatefulWidget {
  final String passengerEmail;

  const UpdatePassengerScreen({super.key, required this.passengerEmail});

  @override
  // ignore: library_private_types_in_public_api
  _UpdatePassengerScreenState createState() => _UpdatePassengerScreenState();
}

class _UpdatePassengerScreenState extends State<UpdatePassengerScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nicNoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _serviceNoController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  String? _selectedGender;
  bool _isInternal = false;
  String? _errorMessage;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  Future<void> _fetchPassengerDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('passenger');

    if (userJson != null) {
      try {
        final data = jsonDecode(userJson);
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _nicNoController.text = data['nicNo'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _contactNoController.text = data['contactNo'] ?? '';
          _serviceNoController.text = data['serviceNo'] ?? '';
          _companyNameController.text = data['companyName'] ?? '';
          _selectedGender = data['gender'] ?? _genderOptions.first;
          _birthdayController.text = data['dateOfBirth'] ?? '';
          _isInternal = data['isInternal'] ?? false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to parse passenger details: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to load passenger details';
      });
    }
  }

  void _handleCancel() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  void initState() {
    super.initState();
    _fetchPassengerDetails();
  }

  Future<void> _handleSubmit() async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final nicNo = _nicNoController.text;
    final username = _usernameController.text;
    final email = _emailController.text;
    final contactNo = _contactNoController.text;
    final serviceNo = _serviceNoController.text;
    final companyName = _companyNameController.text;
    final birthday = _birthdayController.text;
    final gender = _selectedGender;
    final isInternal = _isInternal;

    final response = await http.put(
      Uri.parse('http://localhost:3000/api/v1/passenger/${widget.passengerEmail}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'nicNo': nicNo,
        'username': username,
        'email': email,
        'contactNo': contactNo,
        'serviceNo': serviceNo,
        'companyName': companyName,
        'dateOfBirth': birthday,
        'gender': gender,
        'isInternal': isInternal,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // Save updated user data in local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('passenger', jsonEncode(responseData['data']));

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passenger details updated successfully')),
      );

      // Navigate to the dashboard
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() {
        _errorMessage = 'Failed to update passenger details';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Update Passenger Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                _buildTextField(_firstNameController, 'First Name'),
                _buildTextField(_lastNameController, 'Last Name'),
                _buildTextField(_nicNoController, 'NIC No'),
                _buildTextField(_usernameController, 'Username'),
                _buildTextField(_emailController, 'Email'),
                _buildTextField(_contactNoController, 'Contact No'),
                _buildDropdownButtonFormField('Gender', _genderOptions, _selectedGender, (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                }),
                _buildDatePickerField(context, _birthdayController, 'Birthday'),
                SwitchListTile(
                  title: const Text(
                    'Internal user?',
                    style: TextStyle(fontSize: 18.0, color: Colors.red),
                  ),
                  value: _isInternal,
                  onChanged: (bool value) {
                    setState(() {
                      _isInternal = value;
                    });
                  },
                ),
                if (_isInternal) _buildTextField(_companyNameController, 'Company Name'),
                if (_isInternal) _buildTextField(_serviceNoController, 'Service No'),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _handleSubmit,
                        child: const Text('UPDATE'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _handleCancel,
                        // ignore: sort_child_properties_last
                        child: const Text('CANCEL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Change the color to red
                        ),
                      ),
              ],
            ),
          ),
              ],
        ),
          ),
          ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownButtonFormField(String label, List<String> options, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        readOnly: true,
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() {
              controller.text = picked.toIso8601String().split('T')[0];
            });
          }
        },
      ),
    );
  }
}
