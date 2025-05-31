import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:secondpeacem/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:secondpeacem/providers/cart_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  String? errorMessage;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Email dan password wajib diisi.";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await AuthService().loginUser(
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        final user = response['user'] ?? {};
        final token = response['token'] ?? "";

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setInt('userId', user['id'] ?? 0);
        await prefs.setString('userName', user['nama'] ?? 'Pengguna');
        await prefs.setString('userEmail', user['email'] ?? '-');
        await prefs.setInt('navIndex', 2);

        Provider.of<CartProvider>(context, listen: false).updateToken(token);

        try {
          await Provider.of<CartProvider>(
            context,
            listen: false,
          ).fetchCart(); // ✅ tanpa userId
        } catch (e) {
          debugPrint("Gagal memuat cart: $e");
        }

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } else {
        setState(() {
          errorMessage = response['message'] ?? "Login gagal.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Terjadi kesalahan koneksi.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[700],
                  ),
                  onPressed: toggleObscure,
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () async {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt(
                      'navIndex',
                      2,
                    ); // buka tab Akun di MainScreen
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  }
                },

                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                ),
                label: const Text(
                  "Back",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),

              const Text(
                'LogIn',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              _buildTextField(controller: emailController, hint: "Email"),
              const SizedBox(height: 16),
              _buildTextField(
                controller: passwordController,
                hint: "Password",
                isPassword: true,
                obscureText: _obscurePassword,
                toggleObscure: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t Have an Account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  "By continuing, you agree to our Terms of Service and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
