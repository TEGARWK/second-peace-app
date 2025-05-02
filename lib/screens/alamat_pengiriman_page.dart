import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AlamatPengirimanPage extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const AlamatPengirimanPage({super.key, this.existingData});

  @override
  State<AlamatPengirimanPage> createState() => _AlamatPengirimanPageState();
}

class _AlamatPengirimanPageState extends State<AlamatPengirimanPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _alamatLengkapController;

  bool isUtama = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
      text: widget.existingData?['nama'] ?? '',
    );
    _noHpController = TextEditingController(
      text: widget.existingData?['no_whatsapp'] ?? '',
    );
    _alamatLengkapController = TextEditingController(
      text: widget.existingData?['alamat'] ?? '',
    );
    isUtama =
        widget.existingData?['utama'] == 1 ||
        widget.existingData?['utama'] == true;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _alamatLengkapController.dispose();
    super.dispose();
  }

  Future<void> _simpanAlamat() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final result =
            widget.existingData == null
                ? await AuthService().addAddress(
                  nama: _namaController.text.trim(),
                  telepon: _noHpController.text.trim(),
                  alamat: _alamatLengkapController.text.trim(),
                  kota: "-", // tidak digunakan
                  kodePos: "-", // tidak digunakan
                  utama: isUtama,
                )
                : await AuthService().updateAddress(
                  id: widget.existingData!['id_alamat'],
                  nama: _namaController.text.trim(),
                  telepon: _noHpController.text.trim(),
                  alamat: _alamatLengkapController.text.trim(),
                  kota: "-",
                  kodePos: "-",
                  utama: isUtama,
                );

        if (result['success'] == true) {
          Navigator.pop(context, true);
        } else {
          _showError(result['message'] ?? 'Gagal menyimpan alamat.');
        }
      } catch (e) {
        _showError('Terjadi kesalahan saat menyimpan alamat.');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingData == null ? "Tambah Alamat" : "Edit Alamat",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Form Alamat Pengiriman",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Nama Penerima", _namaController),
                  _buildTextField(
                    "Nomor WhatsApp",
                    _noHpController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    "Alamat Lengkap",
                    _alamatLengkapController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Switch(
                        value: isUtama,
                        activeColor: Colors.green,
                        onChanged: (value) {
                          setState(() => isUtama = value);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Jadikan alamat ini sebagai alamat utama",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      onPressed: isLoading ? null : _simpanAlamat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      label: Text(
                        isLoading
                            ? "Menyimpan..."
                            : widget.existingData == null
                            ? "Simpan Alamat"
                            : "Update Alamat",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value!.isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }
}
