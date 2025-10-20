import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/auth_storage.dart';
import '../providers/project_provider.dart';
import 'profile_screen.dart';
import 'task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().fetchProjects();
    });
  }

  Future<void> _loadUser() async {
    final user = await AuthStorage.getUser();
    setState(() {
      userName = user?['name'] ?? 'Unknown';
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _showCreateProjectDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();


    //Dialogue Box

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            TextField(
              controller: descController,
              decoration:
              const InputDecoration(labelText: 'Description (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final provider = context.read<ProjectProvider>();
              final success =
              await provider.addProject(name, descController.text.trim());

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Project created successfully'),
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _projectsList() {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.projects.isEmpty) {
          return const Center(
            child: Text(
              'No projects found.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: provider.fetchProjects,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: provider.projects.length,
            itemBuilder: (context, index) {
              final p = provider.projects[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    p['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    p['description']?.isNotEmpty == true
                        ? p['description']
                        : 'No description',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  trailing: Text(
                    p['created_at']?.toString().substring(0, 10) ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _homeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Text(
            'Welcome, ${userName ?? ''} 👋',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
          child: Text(
            'Your Projects',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        Expanded(child: _projectsList()),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _homeTab();
      case 1:
        return const TaskScreen();
      case 2:
        return const ProfileScreen();
      default:
        return _homeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text(
          'Task Manager',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () => context.read<ProjectProvider>().fetchProjects(),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            label: 'Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
