
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    if (!_isEmailValid(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'The email address is badly formatted.',
      );
    }
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password, String name) async {
    if (!_isEmailValid(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'The email address is badly formatted.',
      );
    }
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'balance': 0, // Initialize balance
      });
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
