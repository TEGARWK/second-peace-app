import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('userName') ?? '';
      emailController.text = prefs.getString('userEmail') ?? '';
      phoneController.text = prefs.getString('userPhone') ?? '';
      isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data!')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', nameController.text);
    await prefs.setString('userEmail', emailController.text);
    await prefs.setString('userPhone', phoneController.text);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profil berhasil disimpan!')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Edit Profil'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                // Akan diganti dengan Image Picker nanti
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ganti foto coming soon!'),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.black,
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informasi Akun",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 10),
                        _buildInputCard(
                          "Nama Lengkap",
                          nameController,
                          Icons.person,
                        ),
                        const SizedBox(height: 16),
                        _buildInputCard(
                          "Email",
                          emailController,
                          Icons.email,
                          TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildInputCard(
                          "No. Telepon",
                          phoneController,
                          Icons.phone,
                          TextInputType.phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          "Simpan Perubahan",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInputCard(
    String label,
    TextEditingController controller,
    IconData icon, [
    TextInputType inputType = TextInputType.text,
  ]) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextField(
          controller: controller,
          keyboardType: inputType,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.black87),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
