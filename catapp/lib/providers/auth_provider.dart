/* import 'package:catapp/controllers/auth_controller.dart';
import 'package:catapp/models/user.dart';
import 'package:flutter/material.dart';


class AuthProvider extends ChangeNotifier {
  User? _user;
  final AuthController _authController = AuthController();

  User? get user => _user;

  Future<bool> signUp(String email, String password, String firstName, String lastName) async {
    final user = await _authController.signUp(email, password, firstName, lastName);
    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    final user = await _authController.login(email, password);
    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
} */