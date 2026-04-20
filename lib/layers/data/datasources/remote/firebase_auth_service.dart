import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        throw Exception("The password provided is too weak.");
      } else if (e.code == "email-already-in-use") {
        throw Exception("The account already exists for that email.");
      } else if (e.code == "invalid-email") {
        throw Exception("The email address is not valid.");
      } else {
        throw Exception(
          e.message ?? "An error occurred while creating the account.",
        );
      }
    }
  }

  Future<UserCredential> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw Exception('Invalid email or password.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      }
      throw Exception(e.message ?? 'An unknown login error occurred.');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
