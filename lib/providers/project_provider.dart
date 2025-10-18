import 'package:flutter/material.dart';
import '../repository/project_repository.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectRepository _repo = ProjectRepository();

  bool _loading = false;
  List<dynamic> _projects = [];

  bool get loading => _loading;
  List<dynamic> get projects => _projects;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Future<void> fetchProjects() async {
    _setLoading(true);
    _projects = await _repo.getAllProjects();
    _setLoading(false);
  }

  Future<bool> addProject(String name, String? description) async {
    _setLoading(true);
    final result = await _repo.createProject(name, description);
    _setLoading(false);
    if (result != null) {
      _projects.insert(0, result);
      notifyListeners();
      return true;
    }
    return false;
  }
}
