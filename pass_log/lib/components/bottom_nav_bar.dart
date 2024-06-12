import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'dart:convert';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected, 
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {

  void handleLogout(BuildContext context) async {
    final response = await http.get(Uri.parse('http://localhost:3000/api/v1/passenger/logout'));

    if (response.statusCode == 204) {
     // Map<String, dynamic> data = json.decode(response.body);
     // if (data['status']) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Logout Confirmation'),
              content: const Text('Are you sure you want to logout?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false); // Navigate to login and clear stack
                  },
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        );
      }
    /*} else {
      // ignore: avoid_print
      print('Error: ${response.reasonPhrase}');
    }*/
  }

  void _onAccountMenuSelected(String value) {
    switch (value) {
      case 'Update Details':
        Navigator.pushNamed(context, '/get_email');
        break;
      case 'Logout':
        handleLogout(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accessing the theme's color scheme to use the secondary color
    final colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menu',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Romodo',
        ),
        BottomNavigationBarItem(
          icon: PopupMenuButton<String>(
            icon: Icon(Icons.account_circle, color: widget.selectedIndex == 3 ? colorScheme.secondary : colorScheme.secondary.withOpacity(0.6)),
            onSelected: _onAccountMenuSelected,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Update Details',
                child: Text('Update Details'),
              ),
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ],
          ),
          label: 'Account',
        ),
      ],
      currentIndex: widget.selectedIndex,
      // Using colorScheme.secondary for selected item color
      selectedItemColor: colorScheme.secondary,
      // Customizing the unselected item color for better visibility
      unselectedItemColor: colorScheme.secondary.withOpacity(0.6),
      // Customizing the label color to match the icon color
      selectedLabelStyle: TextStyle(color: colorScheme.secondary),
      unselectedLabelStyle:
          TextStyle(color: colorScheme.secondary.withOpacity(0.6)),
      onTap: (index) {
        if (index != 3) {
          widget.onItemSelected(index);
        }
      },
    );
  }
}