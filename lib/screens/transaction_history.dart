import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  late Future<List<Map<String, dynamic>>> _currentFuture;

  @override
  void initState() {
    super.initState();
    _currentFuture = _fetchTransactions();
  }

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .get();

      return transactionsSnapshot.docs
          .map((doc) => {
                'type': doc['type'] ?? '',
                'amount': doc['amount'] ?? 0,
                'timestamp': doc['timestamp'].toDate() ?? DateTime.now(),
                'recipient': doc['recipient'] ?? '',
                'sender': doc['sender'] ?? ''
              })
          .toList();
    }

    return [];
  }

  Future<void> _reloadData() async {
    setState(() {
      _currentFuture = _fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _currentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching transactions.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No transactions found.'));
          }

          final transactions = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final currentUserEmail = FirebaseAuth.instance.currentUser!.email!;

                      String titleText = '';
                      String subtitleText = '';
                      String padd = '                                               ';
                      if (transaction['recipient'] == currentUserEmail) {
                        titleText = 'Received from:';
                        subtitleText = transaction['sender'];
                      } else if (transaction['sender'] == currentUserEmail) {
                        titleText = 'Paid to:';
                        subtitleText = transaction['recipient'];
                      }
                      if (transaction['recipient'] == transaction['sender']) {
                        if (transaction['type'] == 'deposit') {
                          titleText = 'Deposited';
                        } else {
                          titleText = 'Withdrawal';
                        }
                      }
                      titleText = padd + titleText;
                      subtitleText = padd + subtitleText;

                      return ListTile(
                        leading: Text('\$${transaction['amount']}'),
                        leadingAndTrailingTextStyle:TextStyle(fontSize: 15),
                        title: Text('${titleText}'),
                        subtitle: Text('${subtitleText}'),
                        trailing: Text(DateFormat.yMd().add_jms().format(transaction['timestamp'])),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 39, 119, 184))),
                  onPressed: _reloadData,
                  child: Text('Reload Transactions'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
