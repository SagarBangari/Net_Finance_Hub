

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  late Future<Map<String, dynamic>> _currentFuture;

  @override
  void initState() {
    super.initState();
    _currentFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      return userDoc.data() ?? {};
    }

    return {};
  }

  Future<void> _reloadData() async {
    setState(() {
      _currentFuture = _fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade700,
      ),
      backgroundColor: Colors.lightBlue.shade200,
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _currentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error fetching user data.'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No user data found.'));
            }

            final userData = snapshot.data!;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Welcome to Net Finance Hub, the only app you need for banking. ',
                        style: TextStyle(color: Colors.pink),
                      ),
                      TextSpan(
                        text: 'Let\'s Explore',
                        style: TextStyle(color: Colors.pink),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlassBox(
                      username: userData['name'] ?? 'User',
                      email: userData['email']?.toString() ?? '',
                      phone: userData['phone'] ?? '',
                    ),
                    SizedBox(width: 20),
                    
                  ],
                ),
                Lottie.asset(
                      'assets/animations/bank.json',
                      width: 200,
                      height: 200,
                    ),
                   
              ],
            );
          },
        ),
      ),
    );
  }
}

class GlassBox extends StatelessWidget {
  final String username;
  final String email;
  final String phone;

  const GlassBox({
    Key? key,
    required this.username,
    required this.email,
    required this.phone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(20),
          width: 300,
          color: Colors.white.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $username',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Email : $email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Text(
                'Mobile no: $phone',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
