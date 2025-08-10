import 'package:client/main.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String token = '';
  Future<void> getToken() async {
    // Simulate fetching token from secure storage or API
    await storage
        .read(key: 'auth_token')
        .then((value) {
          if (value != null) {
            setState(() {
              // Update the UI with the token
              token = value;
              print('Token fetched: $value');
            });
          } else {
            print('No token found');
          }
        })
        .catchError((error) {
          print('Error fetching token: $error');
        });
  }

  @override
  initState() {
    super.initState();
    // Fetch the token when the page is initialized
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Homepage')),
      body: Center(
        child: Column(
          children: [
            Text('Welcome to the Homepage!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Token: $token'),
          ],
        ),
      ),
    );
  }
}
