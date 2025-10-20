import 'package:flutter/material.dart';
import '../repository/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repo = TaskRepository();

  bool _loading = false;
  List<dynamic> _tasks = [];

  bool get loading => _loading;
  List<dynamic> get tasks => _tasks;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    _setLoading(true);
    _tasks = await _repo.getAllTasks();
    _setLoading(false);
  }

  Future<bool> addTask({
    required String title,
    required String description,
    required String dueDate,
    required String priority,
  }) async {
    _setLoading(true);
    final result = await _repo.createTask(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );
    _setLoading(false);
    if (result != null) {
      _tasks.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }
}
