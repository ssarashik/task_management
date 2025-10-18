import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../data/auth_storage.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final data = await auth.getProfile();
      setState(() {
        _user = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _user = null;
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you really want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      await AuthStorage.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Failed to load profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                backgroundImage: _user?['avatar_url'] != null
                    ? NetworkImage(_user!['avatar_url'])
                    : null,
                child: _user?['avatar_url'] == null
                    ? const Icon(Icons.person, size: 60, color: Colors.blueAccent)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                _user?['name'] ?? 'Unknown',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_user?['email'] ?? 'No email'),
              const SizedBox(height: 8),
              Text("Phone: ${_user?['mobile'] ?? 'Not set'}"),
              const SizedBox(height: 8),
              Text("Gender: ${_user?['gender'] ?? 'Not set'}"),
              const SizedBox(height: 20),
              Text(
                "Joined: ${_user?['created_at'] != null ? _user!['created_at'].toString().split('T').first : 'Unknown'}",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout'),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

