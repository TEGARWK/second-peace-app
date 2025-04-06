import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:secondpeacem/data/dummy_accounts.dart';
import 'package:secondpeacem/main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? errorMessage;
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      errorMessage = null;
      _isLoading = true;
    });

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Semua field wajib diisi.";
        _isLoading = false;
      });
      return;
    }

    final isExist = dummyAccounts.any((user) => user['email'] == email);
    if (isExist) {
      setState(() {
        errorMessage = "Email sudah terdaftar.";
        _isLoading = false;
      });
      return;
    }

    // Hitung ID baru
    final newUserId = dummyAccounts.length + 1;

    // Simulasi simpan akun baru ke dummyAccounts
    dummyAccounts.add({
      'id': newUserId,
      'name': name,
      'email': email,
      'password': password,
      'addresses': [], // Inisialisasi list alamat kosong
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', newUserId);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Daftar", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
