import 'package:flutter/material.dart';
import '../repository/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    final success = await _repo.login(email, password);
    setLoading(false);
    return success;
  }

  Future<bool> register(
      String name,
      String email,
      String password,
      String mobile,
      String gender,
      ) async {
    setLoading(true);
    final success = await _repo.register(name, email, password, mobile, gender);
    setLoading(false);
    return success;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    setLoading(true);
    final profile = await _repo.getProfile();
    setLoading(false);
    return profile;
  }

  Future<void> logout() async {
    setLoading(true);
    await _repo.logout();
    setLoading(false);
    notifyListeners();
  }
}
