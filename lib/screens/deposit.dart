// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class DepositPage extends StatefulWidget {
//   const DepositPage({Key? key}) : super(key: key);
//
//   @override
//   State<DepositPage> createState() => _DepositPageState();
// }
//
// class _DepositPageState extends State<DepositPage> {
//   final TextEditingController _amountController = TextEditingController();
//   bool isLoading = false;
//   String errorMessage = '';
//   Future<void> _deposit() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = 'loading';
//     });
//     try {
//
//       final amount = double.parse(_amountController.text.trim());
//       final user = FirebaseAuth.instance.currentUser;
//
//       if (user != null) {
//         final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
//         await userRef.update({
//           'balance': FieldValue.increment(amount),
//         });
//
//         await userRef.collection('transactions').add({
//           'type': 'deposit',
//           'amount': amount,
//           'timestamp': FieldValue.serverTimestamp(),
//            'recipient': null ,
//           'sender': null
//         });
//         setState(() {
//           isLoading = false;
//           errorMessage = 'Deposit succsseful!!';
//         });
//       }
//
//
//     } catch (e) {
//       print(e.toString());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Deposit'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _amountController,
//               decoration: InputDecoration(labelText: 'Amount',
//               border: const OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 30,),
//               if (isLoading)
//                   const CircularProgressIndicator()
//                 else
//             ElevatedButton(
//               style:ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 39, 119, 184))),
//               onPressed: _deposit ,
//               child: Text('Deposit'),
//             ),
//              Text(errorMessage ,style: TextStyle(color: Colors.red),)
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DepositPage extends StatefulWidget {
  const DepositPage({Key? key}) : super(key: key);

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final TextEditingController _amountController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _deposit() async {
    setState(() {
      isLoading = true;
      errorMessage = 'loading';
    });
    try {
      final amount = double.parse(_amountController.text.trim());
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await userRef.update({
          'balance': FieldValue.increment(amount),
        });

        await userRef.collection('transactions').add({
          'type': 'deposit',
          'amount': amount,
          'timestamp': FieldValue.serverTimestamp(),
          'recipient': null,
          'sender': null,
        });
        setState(() {
          isLoading = false;
          errorMessage = 'Deposit successful!!';
        });
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
        title: Text('Deposit'),
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
                onPressed: _deposit,
                child: Text('Deposit', style: TextStyle(color: Colors.white)),
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
