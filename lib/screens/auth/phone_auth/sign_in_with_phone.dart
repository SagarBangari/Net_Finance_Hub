import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'verify_otp.dart';  // Ensure this file exists and is correctly implemented

class SignInWithPhone extends StatefulWidget {
  const SignInWithPhone({Key? key}) : super(key: key);

  @override
  State<SignInWithPhone> createState() => _SignInWithPhoneState();
}

class _SignInWithPhoneState extends State<SignInWithPhone> {
  TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  void sendOTP() async {
    setState(() {
      isLoading = true;
      errorMessage = 'loading';
    });

    String phone = "+91" + phoneController.text.trim();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolving cases
        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => VerifyOtpScreen(
              verificationId: credential.verificationId ?? '',
            ),
          ),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        log(e.code.toString());
        setState(() {
          isLoading = false;
          errorMessage = e.message ?? 'Verification failed';
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          isLoading = false;
        });

         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent to the entered mobile no.')));
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => VerifyOtpScreen(
              verificationId: verificationId,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          isLoading = false;
        });
      },
      timeout: const Duration(seconds: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sign In with Phone"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Column(
              children: [
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    prefix: const Text("+91 "),
                    errorText: errorMessage.isEmpty ? null : errorMessage,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  CupertinoButton(
                    onPressed: sendOTP,
                    color: Colors.blue,
                    child: const Text("Sign In"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
