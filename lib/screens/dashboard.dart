import 'package:flutter/material.dart';
import 'deposit.dart';
import 'withdraw.dart';
import 'transfer.dart';
import 'profile.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
               style:ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 44, 121, 185))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DepositPage()),
                );
              },
              child: Text('Deopsit'),
            ),
               SizedBox(height: 30,),
             ElevatedButton(
              style:ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 44, 121, 185))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WithdrawPage()),
                );
              },
              child: Text('Withdraw'),
            ),
            SizedBox(height: 30,),
             ElevatedButton(
              style:ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 44, 121, 185))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransferPage()),
                );
              },
              child: Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}
