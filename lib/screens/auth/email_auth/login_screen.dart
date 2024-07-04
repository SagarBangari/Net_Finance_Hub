import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import '../../../main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'forgot_password.dart';
import 'package:email_validator/email_validator.dart';
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
  bool _isEmailValid = false;
  void login() async {
    setState(() {
      isLoading = true;
      error = 'loading';
    });
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
   RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
   bool isValidEmail = emailRegex.hasMatch(email);
   if(!isValidEmail){
     isLoading = false;
      error="Enter valid email";
   }
   else  if(email == "" || password == "") {
      isLoading = false;
      error="Please fill all the fields!";
    }
    else if(password.length <6){
      isLoading = false;
      error = "password should be at least 6 charecters long ";
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
          
        }
        
      } on FirebaseAuthException catch(ex) {
        setState(() {
          isLoading = false;
          switch (ex.code) {
            case 'user-not-found':
              error = 'No user found for that email.';
              break;
            case 'wrong-password':
              error = 'Wrong password provided for that user.';
              break;
            case 'invalid-email':
              error = 'The email address is not valid.';
              break;
            default:
              error = 'Wrong password provided for that user';
              break;
          }
        });
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
