import 'package:e_commerce_app/layers/data/models/user_model.dart';
import 'package:e_commerce_app/layers/domain/repositories_impl/auth_repository_impl.dart';
import 'package:e_commerce_app/layers/domain/repositories_impl/cart_repository_impl.dart';
import 'package:e_commerce_app/layers/domain/repositories_impl/wishlist_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthViewmodel extends ChangeNotifier {
  final AuthRepositoryImpl _authRepositoryImpl;
  final CartRepositoryImpl _cartRepositoryImpl;
  final WishlistRepository _wishlistRepository;

  UserModel? _userProfile;
  UserModel? get userProfile => _userProfile;
  bool _isProfileLoading = false;
  bool get isProfileLoading => _isProfileLoading;
  String? _profileErrorMessage;
  String? get profileErrorMessage => _profileErrorMessage;

  AuthViewmodel(
    this._authRepositoryImpl,
    this._cartRepositoryImpl,
    this._wishlistRepository,
  ) {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      _currentUser = user;
      if (user == null) {
        _userProfile = null;
        _profileErrorMessage = null;
        _isProfileLoading = false;
        notifyListeners();
        return;
      }

      _isProfileLoading = true;
      _profileErrorMessage = null;
      notifyListeners();

      try {
        await _loadUserProfile(user);
        await _cartRepositoryImpl.syncLocalCartToFirestore(user.uid);
        await _wishlistRepository.syncLocalWishlistToFirestore(user.uid);
      } catch (e) {
        _userProfile = null;
        _profileErrorMessage = _formatError(e);
      } finally {
        _isProfileLoading = false;
        notifyListeners();
      }
    });
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoginPasswordObscured = true;
  bool get isLoginPasswordObscured => _isLoginPasswordObscured;

  bool _isRegisterPasswordObscured = true;
  bool get isRegisterPasswordObscured => _isRegisterPasswordObscured;

  bool _isRegisterConfirmPasswordObscured = true;
  bool get isRegisterConfirmPasswordObscured =>
      _isRegisterConfirmPasswordObscured;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  Future<bool> registerUserWithEmailAndPassword({
    required String name,
    required String surname,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      _errorMessage = "Passwords do not match";
      notifyListeners();
      return false;
    }

    final formattedName = formatNameInput(name.trim());
    final formattedSurname = formatNameInput(surname.trim());

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepositoryImpl.registerUser(
        name: formattedName,
        surname: formattedSurname,
        email: email,
        password: password,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _loadUserProfile(user);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepositoryImpl.loginUser(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _formatError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _formatError(Object error) {
    final message = error.toString();
    if (message.startsWith("Exception: ")) {
      return message.substring("Exception: ".length);
    }
    return message;
  }

  Future<void> _loadUserProfile(User user) async {
    _userProfile = await _authRepositoryImpl.ensureUserProfile(user);
    _profileErrorMessage = null;
  }

  String formatNameInput(String value) {
    if (value.isEmpty) {
      return value;
    }

    final buffer = StringBuffer();
    var shouldCapitalize = true;

    for (final rune in value.runes) {
      final character = String.fromCharCode(rune);
      final isLetter = character.toUpperCase() != character.toLowerCase();

      if (isLetter) {
        buffer.write(shouldCapitalize ? character.toUpperCase() : character);
        shouldCapitalize = false;
        continue;
      }

      buffer.write(character);
      if (character == ' ' || character == '-' || character == '\'') {
        shouldCapitalize = true;
      }
    }

    return buffer.toString();
  }

  void toggleLoginPasswordVisibility() {
    _isLoginPasswordObscured = !_isLoginPasswordObscured;
    notifyListeners();
  }

  void toggleRegisterPasswordVisibility() {
    _isRegisterPasswordObscured = !_isRegisterPasswordObscured;
    notifyListeners();
  }

  void toggleRegisterConfirmPasswordVisibility() {
    _isRegisterConfirmPasswordObscured = !_isRegisterConfirmPasswordObscured;
    notifyListeners();
  }

  void resetLoginPasswordVisibility() {
    if (_isLoginPasswordObscured) {
      return;
    }
    _isLoginPasswordObscured = true;
    notifyListeners();
  }

  void resetRegisterPasswordVisibility() {
    var hasChanged = false;

    if (!_isRegisterPasswordObscured) {
      _isRegisterPasswordObscured = true;
      hasChanged = true;
    }

    if (!_isRegisterConfirmPasswordObscured) {
      _isRegisterConfirmPasswordObscured = true;
      hasChanged = true;
    }

    if (hasChanged) {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepositoryImpl.signOut();
  }
}
