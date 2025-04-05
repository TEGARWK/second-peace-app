// === alamat_pengiriman_page.dart ===
import 'package:flutter/material.dart';

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
  late TextEditingController _kotaController;
  late TextEditingController _kodePosController;

  bool isUtama = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(
      text: widget.existingData?['nama'] ?? '',
    );
    _noHpController = TextEditingController(
      text: widget.existingData?['telepon'] ?? '',
    );
    _alamatLengkapController = TextEditingController(
      text: widget.existingData?['alamat'] ?? '',
    );
    _kotaController = TextEditingController(
      text: widget.existingData?['kota'] ?? '',
    );
    _kodePosController = TextEditingController(
      text: widget.existingData?['kodePos'] ?? '',
    );
    isUtama = widget.existingData?['utama'] ?? false;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _alamatLengkapController.dispose();
    _kotaController.dispose();
    _kodePosController.dispose();
    super.dispose();
  }

  void _simpanAlamat() {
    if (_formKey.currentState!.validate()) {
      final newAlamat = {
        'nama': _namaController.text.trim(),
        'telepon': _noHpController.text.trim(),
        'alamat': _alamatLengkapController.text.trim(),
        'kota': _kotaController.text.trim(),
        'kodePos': _kodePosController.text.trim(),
        'utama': isUtama,
      };
      Navigator.pop(context, newAlamat);
    }
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
        backgroundColor: const Color.fromARGB(255, 32, 32, 32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Nama Penerima", _namaController),
              _buildTextField(
                "Nomor HP",
                _noHpController,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                "Alamat Lengkap",
                _alamatLengkapController,
                maxLines: 2,
              ),
              _buildTextField("Kota", _kotaController),
              _buildTextField(
                "Kode Pos",
                _kodePosController,
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text("Jadikan Alamat Utama"),
                value: isUtama,
                onChanged: (value) {
                  setState(() {
                    isUtama = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _simpanAlamat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  widget.existingData == null ? "Simpan" : "Update",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value!.isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }
}
