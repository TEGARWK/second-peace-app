import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:secondpeacem/screens/register_page.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final auth = AuthService();
        final result = await auth.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        final token = result['token'];
        final name = result['user']['name'];
        final email = result['user']['email'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userToken', token);
        await prefs.setString('userName', name);
        await prefs.setString('userEmail', email);
        await prefs.setInt('navIndex', 2);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login Berhasil!')));

        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login gagal: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                const Text(
                  "LogIn",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildInputField(
                  controller: _emailController,
                  label: 'Email Address',
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  toggleObscure: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't Have an Account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSocialButton(
                  icon: FontAwesomeIcons.google,
                  label: "Continue With Google",
                  iconColor: Colors.red,
                ),
                const SizedBox(height: 12),
                _buildSocialButton(
                  icon: FontAwesomeIcons.facebook,
                  label: "Continue With Facebook",
                  iconColor: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    VoidCallback? toggleObscure,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) => value!.isEmpty ? '$label wajib diisi' : null,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: toggleObscure,
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color iconColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: FaIcon(icon, color: iconColor),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(label, style: const TextStyle(color: Colors.black)),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.grey[100],
        ),
      ),
    );
  }
}
