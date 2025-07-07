/* 
import 'package:catapp/models/user.dart';
import 'package:catapp/services/database_service.dart';

class AuthController {
  final DatabaseService _databaseService = DatabaseService();

  Future<User?> signUp(String email, String password, String firstName, String lastName) async {
    try {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        password: password, // In production, hash the password
        firstName: firstName,
        lastName: lastName,
        createdOn: DateTime.now(),
      );
      await _databaseService.insertUser(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final user = await _databaseService.getUserByEmail(email);
      if (user != null && user.password == password) {
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} */