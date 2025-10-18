import 'package:dio/dio.dart';
import '../core/api_client.dart';

class ProjectRepository {
  // সব প্রজেক্ট লোড করা
  Future<List<dynamic>> getAllProjects() async {
    try {
      final response = await ApiClient.dio.get('/projects');
      if (response.statusCode == 200 && response.data is List) {
        return response.data;
      }
    } on DioException catch (e) {
      print('Fetch projects error: ${e.response?.data ?? e.message}');
    }
    return [];
  }

  // নতুন প্রজেক্ট তৈরি করা
  Future<Map<String, dynamic>?> createProject(String name, String? description) async {
    try {
      final response = await ApiClient.dio.post('/projects', data: {
        'name': name,
        'description': description ?? '',
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
    } on DioException catch (e) {
      print('Create project error: ${e.response?.data ?? e.message}');
    }
    return null;
  }
}
