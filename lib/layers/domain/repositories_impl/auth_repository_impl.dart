import 'package:e_commerce_app/layers/data/datasources/remote/firebase_auth_service.dart';
import 'package:e_commerce_app/layers/data/datasources/remote/firebase_firestore_service.dart';
import 'package:e_commerce_app/layers/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthRepositoryImpl {
  final FirebaseAuthService _service;
  final FirebaseFirestoreService _firestoreService;

  AuthRepositoryImpl(this._service, this._firestoreService);

  Future<void> registerUser({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _service.registerWithEmailAndPassword(
        email,
        password,
      );

      final uid = credential.user?.uid;
      if (kDebugMode) {
        print("Uid: $uid");
      }
      if (uid == null) {
        throw Exception("Registration failed because no user id was returned.");
      }

      await _updateDisplayName(credential.user, name, surname);

      final userModel = UserModel(
        uid: uid,
        name: name,
        surname: surname,
        email: email,
      );
      try {
        await _firestoreService.saveUserProfile(userModel);
      } catch (e) {
        final rollbackMessage = await _deleteAuthUserIfNeeded(credential.user);
        throw Exception(
          "Firebase Auth account was created, but saving the user profile failed. "
          "${_errorMessage(e)}$rollbackMessage",
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _service.loginWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _deleteAuthUserIfNeeded(User? user) async {
    if (user == null) {
      return "";
    }

    try {
      await user.delete();
      return " The Auth account was rolled back automatically.";
    } catch (_) {
      return " Please delete the partially created Auth user from Firebase Console and try again.";
    }
  }

  String _errorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith("Exception: ")) {
      return message.substring("Exception: ".length);
    }
    return message;
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      return await _firestoreService.getUserProfile(uid);
    } catch (e) {
      throw Exception("Failed to fetch user profile: ${_errorMessage(e)}");
    }
  }

  Future<UserModel> ensureUserProfile(User user) async {
    final existingProfile = await getUserProfile(user.uid);
    if (existingProfile != null) {
      return existingProfile;
    }

    final generatedProfile = _buildFallbackProfile(user);
    await _firestoreService.saveUserProfile(generatedProfile);
    return generatedProfile;
  }

  Future<void> signOut() async {
    await _service.logout();
  }

  Future<void> _updateDisplayName(
    User? user,
    String name,
    String surname,
  ) async {
    if (user == null) {
      return;
    }

    final fullName = [name.trim(), surname.trim()]
        .where((part) => part.isNotEmpty)
        .join(' ');

    if (fullName.isEmpty) {
      return;
    }

    try {
      await user.updateDisplayName(fullName);
      await user.reload();
    } catch (_) {
      // Firestore remains the primary source of truth for the app profile.
    }
  }

  UserModel _buildFallbackProfile(User user) {
    final nameParts = _deriveNameParts(user);
    final email = user.email?.trim() ?? "";

    return UserModel(
      uid: user.uid,
      name: nameParts.$1,
      surname: nameParts.$2,
      email: email,
    );
  }

  (String, String) _deriveNameParts(User user) {
    final displayName = user.displayName?.trim() ?? "";
    if (displayName.isNotEmpty) {
      final parts = displayName.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
      final firstName = parts.first;
      final surname = parts.length > 1 ? parts.sublist(1).join(' ') : "User";
      return (firstName, surname);
    }

    final emailPrefix = (user.email?.split('@').first ?? "").trim();
    final tokens = emailPrefix
        .split(RegExp(r'[._-]+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (tokens.isEmpty) {
      return ("Guest", "User");
    }

    if (tokens.length == 1) {
      return (_capitalize(tokens.first), "User");
    }

    final firstName = _capitalize(tokens.first);
    final surname = tokens.sublist(1).map(_capitalize).join(' ');
    return (firstName, surname);
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}
