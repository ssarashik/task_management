import 'package:dio/dio.dart';
import '../core/api_client.dart';

class TaskRepository {
  // সব task লোড করা
  Future<List<dynamic>> getAllTasks() async {
    try {
      final response = await ApiClient.dio.get('/tasks');
      if (response.statusCode == 200 && response.data['data'] is List) {
        return response.data['data'];
      }
    } on DioException catch (e) {
      print('Fetch tasks error: ${e.response?.data ?? e.message}');
    }
    return [];
  }

  // নতুন task তৈরি করা
  Future<Map<String, dynamic>?> createTask({
    required String title,
    required String description,
    required String dueDate,
    required String priority,
  }) async {
    try {
      final response = await ApiClient.dio.post('/tasks', data: {
        'title': title,
        'description': description,
        'due_date': dueDate,
        'priority': priority.toLowerCase(),
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data'];
      }
    } on DioException catch (e) {
      print('Create task error: ${e.response?.data ?? e.message}');
    }
    return null;
  }
}
