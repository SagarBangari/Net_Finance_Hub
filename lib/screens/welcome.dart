import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
        title: Text('Home Page'),
      ),
        backgroundColor: Color.fromARGB(255, 103, 102, 102),
      body: Center(
        child: Column(
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
                  text: 'Welcome to Net Finance Hub , The only app you need for banking',
                  style: TextStyle(color: Colors.pink),
                ),
               TextSpan(
                  text: 'Lets Expore',
                  style: TextStyle(color: Colors.pink),
               )
               
              ],
            ),
          ),
          
          ],
        ),
      ),
    );
  }
}