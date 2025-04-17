import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:secondpeacem/main.dart';
import 'package:secondpeacem/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmVisible = false;
  bool _isLoading = false;
  String? errorMessage;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _register() async {
    setState(() {
      errorMessage = null;
      _isLoading = true;
    });

    final nama = nameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final noTelepon = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (nama.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        noTelepon.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        errorMessage = "Semua field wajib diisi.";
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = "Password tidak cocok.";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await AuthService().registerUser(
        nama: nama,
        username: username,
        email: email,
        noTelepon: noTelepon,
        password: password,
      );

      if (response['success'] == true) {
        final user = response['user'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('userId', user['id']);
        await prefs.setString('userName', user['nama']);
        await prefs.setString('userEmail', user['email']);
        await prefs.setString('userPhone', user['no_telepon']);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else {
        setState(() {
          errorMessage = response['message'] ?? "Registrasi gagal.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Terjadi kesalahan: ${e.toString()}";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', account.displayName ?? 'Guest');
        await prefs.setString('userEmail', account.email);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      }
    } catch (error) {
      print("Google sign in error: $error");
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    bool isVisible = false,
    void Function()? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: toggleVisibility,
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(height: 12),
              const Text(
                "Register",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              buildTextField(
                controller: nameController,
                hintText: "Nama Lengkap",
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: usernameController,
                hintText: "Username",
              ),
              const SizedBox(height: 16),
              buildTextField(controller: emailController, hintText: "Email"),
              const SizedBox(height: 16),
              buildTextField(
                controller: phoneController,
                hintText: "Nomor Telepon",
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: passwordController,
                hintText: "Password",
                isPassword: true,
                isVisible: isPasswordVisible,
                toggleVisibility: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 16),
              buildTextField(
                controller: confirmPasswordController,
                hintText: "Konfirmasi Password",
                isPassword: true,
                isVisible: isConfirmVisible,
                toggleVisibility: () {
                  setState(() {
                    isConfirmVisible = !isConfirmVisible;
                  });
                },
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Continue",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Login here",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loginWithGoogle,
                icon: Image.asset("assets/google.png", height: 24),
                label: const Text("Continue With Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F0F0),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
