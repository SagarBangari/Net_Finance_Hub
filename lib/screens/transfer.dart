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
  final TextEditingController _recipientEmailController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  Future<void> _transfer() async {
    setState(() {
      isLoading = true;
      errorMessage = 'loading';
    });
    try {
      final amount = double.parse(_amountController.text.trim());
      final recipientEmail = _recipientEmailController.text.trim();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final recipientQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: recipientEmail)
            .limit(1)
            .get();

        if (recipientQuery.docs.isNotEmpty) {
          final recipientRef = recipientQuery.docs.first.reference;

          await FirebaseFirestore.instance.runTransaction((transaction) async {
            final userSnapshot = await transaction.get(userRef);
            final recipientSnapshot = await transaction.get(recipientRef);

            if (userSnapshot.exists && recipientSnapshot.exists) {
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
                'recipient': recipientEmail,
                'sender' : user.email
              });

              transaction.set(recipientRef.collection('transactions').doc(), {
                'type': 'transfer',
                'amount': amount,              
                'timestamp': FieldValue.serverTimestamp(),
                 'recipient': recipientEmail,
                 'sender': user.email,
              });
            }
            setState(() {
              isLoading = false;
              errorMessage = 'Transfer successful!!';
            });
          });
        } else {
          setState(() {
              errorMessage = 'receipt is not found...';
          });
        
        }
      }
    } catch (e) {
      print(e.toString());
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
            TextField(
              controller: _recipientEmailController,
              decoration: InputDecoration(labelText: 'Recipient Email'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount',
              border: const OutlineInputBorder(),),
              keyboardType: TextInputType.number,
            ),
              if (isLoading)
                  const CircularProgressIndicator()
                else
            ElevatedButton(
              onPressed: _transfer,
              child: Text('Transfer'),
            ),
            Text(errorMessage ,style: TextStyle(color: Colors.red),)
          ],
        ),
      ),
    );
  }
}
