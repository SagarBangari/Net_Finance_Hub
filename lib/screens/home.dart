import 'package:bank/screens/auth/email_auth/login_screen.dart';
import 'package:bank/screens/auth/email_auth/signup_screen.dart';
import 'package:bank/screens/auth/phone_auth/sign_in_with_phone.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                 
              ],
            ),
          ),
           SizedBox(height:30),
             Row(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
              style:ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 44, 121, 185))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Login with email',style: TextStyle(color: Colors.white)),
            ),
             SizedBox(width:30),
              ElevatedButton(
              style:ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 44, 121, 185))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInWithPhone()),
                );
              },
              child: Text('Login with phone ',style: TextStyle(color: Colors.white)),
            ),
             ],),
          
            SizedBox(height: 30,),
             ElevatedButton(
              style:ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 39, 119, 184))),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text('Signup',style: TextStyle(color: Colors.white)),
            ),
          SizedBox(height: 20),
          SizedBox(height: 20),
          SizedBox(height: 20),
          SizedBox(height: 20),
          
          ],
        ),
      ),
    );
  }
}