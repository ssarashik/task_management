import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _taskPriority = 'low';
  DateTime? _dueDate;
  String? _selectedProject;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _createTask() async {
    if (_titleController.text.isEmpty || _dueDate == null) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final success = await taskProvider.addTask(
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _formatDate(_dueDate!),
      priority: _taskPriority,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _taskPriority = 'low';
        _dueDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Projects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedProject,
              hint: const Text('Select Project'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: projectProvider.projects
                  .map(
                    (p) => DropdownMenuItem(
                  value: p['id'].toString(),
                  child: Text(p['name']),
                ),
              )
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedProject = val);
              },
            ),
            const SizedBox(height: 20),

            const Text(
              'Create Task',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: _taskPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (val) {
                setState(() => _taskPriority = val!);
              },
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            InkWell(
              onTap: _pickDueDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(_dueDate != null ? _formatDate(_dueDate!) : ''),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                taskProvider.loading ? null : () => _createTask(),
                child: taskProvider.loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Task'),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Task List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (taskProvider.loading)
              const Center(child: CircularProgressIndicator())
            else if (taskProvider.tasks.isEmpty)
              const Text('No tasks found')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: taskProvider.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskProvider.tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(task['title'] ?? ''),
                      subtitle: Text(
                        'Priority: ${task['priority']}, Due: ${task['due_date']}',
                      ),
                      leading: const Icon(
                        Icons.task_alt_outlined,
                        color: Colors.blueAccent,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
