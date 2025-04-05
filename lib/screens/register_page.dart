import 'package:flutter/material.dart';
import 'package:secondpeacem/screens/login_page.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final auth = AuthService();
        final result = await auth.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register berhasil, silakan login!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Register gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator:
                      (value) => value!.isEmpty ? 'Nama wajib diisi' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator:
                      (value) => value!.isEmpty ? 'Email wajib diisi' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator:
                      (value) =>
                          value!.length < 6 ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Sudah punya akun? Login di sini"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
