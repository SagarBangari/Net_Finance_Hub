
import 'package:firebase_messaging/firebase_messaging.dart';

import '../services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({Key? key}) : super(key: key);

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedRecipientPhone;
  bool isLoading = false;
  String errorMessage = '';
  List<String> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final userQuery = await FirebaseFirestore.instance.collection('users').get();
      final userPhones = userQuery.docs.map((doc) => doc.data()['phone'].toString()).toList();
      setState(() {
        users = userPhones;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to fetch users: ${e.toString()}';
      });
    }
  }

  Future<void> _transfer() async {
    setState(() {
      isLoading = true;
      errorMessage = 'Loading...';
    });
    try {
      final amount = double.parse(_amountController.text.trim());
      final recipientPhone = _selectedRecipientPhone;
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && recipientPhone != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final recipientQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: recipientPhone)
            .limit(1)
            .get();

        if (recipientQuery.docs.isNotEmpty) {
          final recipientRef = recipientQuery.docs.first.reference;

          await FirebaseFirestore.instance.runTransaction((transaction) async {
            final userSnapshot = await transaction.get(userRef);
            final recipientSnapshot = await transaction.get(recipientRef);

            if (userSnapshot.exists && recipientSnapshot.exists) {
              final double userBalance = userSnapshot.data()?['balance'];

              // Check if user has sufficient balance
              if (userBalance >= amount) {
                transaction.update(userRef, {
                  'balance': FieldValue.increment(-amount),
                });
                transaction.update(recipientRef, {
                  'balance': FieldValue.increment(amount),
                });

                transaction.set(userRef.collection('transactions').doc(), {
                  'type': 'transfer',
                  'amount': amount,
                  'timestamp': FieldValue.serverTimestamp(),
                  'recipient': '$recipientPhone@nfh',
                  'sender': user.email,
                });

                transaction.set(recipientRef.collection('transactions').doc(), {
                  'type': 'transfer',
                  'amount': amount,
                  'timestamp': FieldValue.serverTimestamp(),
                  'recipient': '$recipientPhone@nfh',
                  'sender': user.email,
                });
                setState(() {
                  isLoading = false;
                  errorMessage = 'Transfer successful!!';
                });
              } else {
                setState(() {
                  isLoading = false;
                  errorMessage = 'Insufficient balance!';
                });
              }
            }
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'Recipient not found.';
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedRecipientPhone,
              onChanged: (value) {
                setState(() {
                  _selectedRecipientPhone = value;
                });
              },
              items: users.map((phone) {
                return DropdownMenuItem<String>(
                  value: phone,
                  child: Text('$phone@nfh'),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Recipient Phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(height: 30),
            if (isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 39, 119, 184)),
                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15, horizontal: 30)),
                  textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.blueAccent),
                  )),
                  shadowColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.5)),
                  elevation: MaterialStateProperty.all(5),
                ),
                onPressed: _transfer,
                child: Text('Transfer', style: TextStyle(color: Colors.white)),
              ),
            SizedBox(height: 10),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}