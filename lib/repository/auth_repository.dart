import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../data/auth_storage.dart';

class AuthRepository {
  /// Login user
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      if (data['token'] != null && data['user'] != null) {
        await AuthStorage.saveSession(data['token'], data['user']);
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Login error: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  /// Register new user
  Future<bool> register(
      String name,
      String email,
      String password,
      String mobile,
      String gender,
      ) async {
    try {
      final response = await ApiClient.dio.post('/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'mobile': mobile,
        'gender': gender.toLowerCase(),
      });

      final data = response.data;
      if (data['token'] != null && data['user'] != null) {
        await AuthStorage.saveSession(data['token'], data['user']);
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Register error: ${e.response?.data ?? e.message}');
      return false;
    }
  }

  /// Fetch profile (new format)
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await ApiClient.dio.get('/profile');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['id'] != null) {
          await AuthStorage.saveSession(
            await AuthStorage.getToken() ?? '',
            data,
          );
          return data;
        }
      }
    } on DioException catch (e) {
      print('Profile fetch error: ${e.response?.data ?? e.message}');
    }

    // fallback to stored user
    return await AuthStorage.getUser();
  }

  /// Logout user
  Future<bool> logout() async {
    try {
      await ApiClient.dio.post('/logout');
    } catch (_) {}
    await AuthStorage.clear();
    return true;
  }
}
