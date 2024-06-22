import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import '../../../main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'forgot_password.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String error = '';
  void login() async {
    setState(() {
      isLoading = true;
      error = 'loading';
    });
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == "" || password == "") {
      isLoading = false;
      error="Please fill all the fields!";
    }
    else {

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
       setState(() {
         isLoading = false;
       });
        if(userCredential.user != null) {

          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context, CupertinoPageRoute(
            builder: (context) => HomeNavigationPage(0)
          ));
          
        }else{
          isLoading = false;
          error = 'The user is not registered';
        }
        
      } on FirebaseAuthException catch(ex) {
        log(ex.code.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Login"),
      ),
      body: SafeArea(
        child: ListView(
          children: [

            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  
                  TextField(
                    controller: emailController,
                       keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 10,),

                  TextField(
                    controller: passwordController,
                       keyboardType: TextInputType.emailAddress,
                       obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20,),
                    if (isLoading)
                  const CircularProgressIndicator()
                else
                  CupertinoButton(
                    onPressed: () {
                      login();
                    },
                    color: Colors.blue,
                    child: Text("Log In"),
                  ),

                  SizedBox(height: 10,),
                 
                  CupertinoButton(
                    onPressed: () {
                      Navigator.push(context, CupertinoPageRoute(
                        builder: (context) => SignUpScreen()
                      ));
                    },
                    child: Text("Create an Account"),
                  ),
                  SizedBox(height: 20,),
                   CupertinoButton(
                    onPressed: () {
                      Navigator.push(context, CupertinoPageRoute(
                        builder: (context) => ForgotPasswordPage()
                      ));
                    },
                    child: Text("Forgot password"),
                  ),
                  SizedBox(height: 30,),
                    Text('${error}',style: TextStyle(color: Colors.red),)
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}