import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_nav_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditing = false;
  bool _loading = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        _username = doc.data()?['username'] ?? user!.displayName ?? 'Pengguna';
        _usernameController.text = _username!;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _username = user!.displayName ?? 'Pengguna';
        _usernameController.text = _username!;
        _loading = false;
      });
    }
  }

  Future<void> _saveUsername() async {
    final newName = _usernameController.text.trim();
    if (newName.isEmpty) return;
    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'username': newName,
      });
      await user!.updateDisplayName(newName);
      await user!.reload();

      if (!mounted) return;
      setState(() {
        _username = newName;
        _isEditing = false;
        _loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username berhasil diperbarui')),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui username: $e')),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: const Color(0xFF9038FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: const BoxDecoration(
                      color: Color(0xFF9038FF),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person,
                              size: 56, color: Color(0xFF9038FF)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _username ?? '-',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '-',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            suffixIcon: _isEditing
                                ? IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: _saveUsername,
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = true;
                                      });
                                    },
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (!mounted) return;
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavWidget(),
    );
  }
}
