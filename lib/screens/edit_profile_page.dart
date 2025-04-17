import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:secondpeacem/services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  File? _selectedImage;

  bool isLoading = true;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
      nameController.text = prefs.getString('userName') ?? '';
      emailController.text = prefs.getString('userEmail') ?? '';
      phoneController.text = prefs.getString('userPhone') ?? '';
      isLoading = false;
    });
  }

  // Update _pickImage untuk pengecekan izin
  Future<void> _pickImage() async {
    // Request permission to access the photos
    var status =
        await Permission.photos.request(); // or Permission.storage for SDK < 33
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin akses galeri ditolak')),
      );
      return;
    }

    // Jika izin diberikan, pilih gambar
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await AuthService().updateProfile(
        userId: userId!,
        nama: name,
        email: email,
        noTelepon: phone,
        foto: _selectedImage,
      );

      if (response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', name);
        await prefs.setString('userEmail', email);
        await prefs.setString('userPhone', phone);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui.")),
        );
        Navigator.pop(context);
      } else {
        throw Exception(response['message'] ?? "Update gagal");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : null,
                            backgroundColor: Colors.grey,
                            child:
                                _selectedImage == null
                                    ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: _pickImage, // Here is the image pick handler
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.black,
                              child: Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text("Simpan Perubahan"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
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
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.black),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
