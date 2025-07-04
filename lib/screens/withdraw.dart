
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({Key? key}) : super(key: key);

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _amountController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _withdraw() async {
    setState(() {
      isLoading = true;
      errorMessage = 'loading';
    });
    try {
      final amount = double.parse(_amountController.text.trim());
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userData = await userRef.get();
        final double balance = userData.data()?['balance'] ?? 0.0;

        // Check if user has sufficient balance
        if (balance < amount) {
          setState(() {
            isLoading = false;
            errorMessage = 'Insufficient balance!';
          });
          return;
        }
        await userRef.update({
          'balance': FieldValue.increment(-amount),
        });

        await userRef.collection('transactions').add({
          'type': 'withdraw',
          'amount': amount,
          'timestamp': FieldValue.serverTimestamp(),
          'recipient': null,
          'sender': null,
        });
        setState(() {
          isLoading = false;
          errorMessage = 'Withdraw successful!!';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                onPressed: _withdraw,
                child: Text('Withdraw', style: TextStyle(color: Colors.white)),
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
