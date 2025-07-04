
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '../services/auth_service.dart';
import 'home.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  late Future<Map<String, dynamic>> _currentFuture;
  File? _imageFile;

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

  Future<void> _logout(BuildContext context) async {
    await _authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            color: Colors.white,
            iconSize: 28,
            splashRadius: 24,
            splashColor: Colors.redAccent,
            padding: EdgeInsets.all(10),
            tooltip: 'Logout',
            constraints: BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            hoverColor: Color.fromARGB(100, 32, 71, 225),
          ),
        ],
      ),
      body: Container(
        color: Colors.lightBlue.shade200,
        child: Center(
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
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Name: ${userData['name']}',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Email: ${userData['email']}',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Mobile no: ${userData['phone']}',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Balance: \$${userData['balance'] ?? 0}',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 60, 162, 244)),
                          ),
                          onPressed: _reloadData,
                          child: Text('Update balance',style: TextStyle(color: Colors.black87),),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Lottie.asset(
                        'assets/animations/bank.json', // Add your Lottie animation file in the assets folder
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                   
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
