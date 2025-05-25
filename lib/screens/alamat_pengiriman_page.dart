import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/shipping_service.dart';

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

  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> cities = [];

  Map<String, dynamic>? selectedProvince;
  Map<String, dynamic>? selectedCity;

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

    () async {
      await _loadProvinces();
      if (widget.existingData != null) {
        selectedProvince = {
          'id': widget.existingData!['provinsi_id'].toString(),
          'name': widget.existingData!['provinsi_nama'],
        };

        selectedCity = {
          'id': widget.existingData!['kota_id'].toString(),
          'name': widget.existingData!['kota_nama'],
        };

        await _loadCities(widget.existingData!['provinsi_id'].toString());
      }
    }();

    if (widget.existingData != null) {
      selectedProvince = {
        'id': widget.existingData!['provinsi_id'].toString(),
        'name': widget.existingData!['provinsi_nama'],
      };

      selectedCity = {
        'id': widget.existingData!['kota_id'].toString(),
        'name': widget.existingData!['kota_nama'],
      };

      _loadCities(widget.existingData!['provinsi_id'].toString());
      print(cities);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _alamatLengkapController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    try {
      provinces = await ShippingService().getProvinces();
      setState(() {});
    } catch (e) {
      print('Gagal memuat provinsi: $e');
    }
  }

  Future<void> _loadCities(String provinceId) async {
    try {
      cities = await ShippingService().getCities(provinceId);
      setState(() {});
    } catch (e) {
      print('Gagal memuat kota: $e');
    }
  }

  Future<void> _simpanAlamat() async {
    if (_formKey.currentState!.validate()) {
      if (selectedProvince == null || selectedCity == null) {
        _showError('Provinsi dan kota wajib dipilih.');
        return;
      }

      setState(() => isLoading = true);

      try {
        final result =
            widget.existingData == null
                ? await AuthService().addAddress(
                  nama: _namaController.text.trim(),
                  telepon: _noHpController.text.trim(),
                  alamat: _alamatLengkapController.text.trim(),
                  kodePos: '-',
                  kota: selectedCity!['name'],
                  kotaId: double.parse(selectedCity!['id']).toInt(),
                  kotaNama: selectedCity!['name'], // ✅ TAMBAH INI
                  provinsiId: double.parse(selectedProvince!['id']).toInt(),
                  provinsiNama: selectedProvince!['name'], // ✅ TAMBAH INI
                  utama: isUtama,
                )
                : await AuthService().updateAddress(
                  id: widget.existingData!['id_alamat'],
                  nama: _namaController.text.trim(),
                  telepon: _noHpController.text.trim(),
                  alamat: _alamatLengkapController.text.trim(),
                  kodePos: '-',
                  kota: selectedCity!['name'],
                  kotaId: double.parse(selectedCity!['id']).toInt(),
                  kotaNama: selectedCity!['name'],
                  provinsiId: double.parse(selectedProvince!['id']).toInt(),
                  provinsiNama: selectedProvince!['name'],
                  utama: isUtama,
                );

        if (result['success'] == true) {
          print('RESPON API: $result');

          Navigator.pop(context, true);
        } else {
          _showError(result['message'] ?? 'Gagal menyimpan alamat.');
        }
      } catch (e) {
        print('ERROR: $e');
        _showError(e.toString());
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
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Form Alamat Pengiriman",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Nama Penerima", _namaController),
                  _buildTextField(
                    "Nomor WhatsApp",
                    _noHpController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Provinsi',
                    ),
                    value:
                        selectedProvince != null &&
                                provinces.any(
                                  (p) => p['id'] == selectedProvince!['id'],
                                )
                            ? provinces.firstWhere(
                              (p) => p['id'] == selectedProvince!['id'],
                            )
                            : null,
                    items:
                        provinces.map((prov) {
                          return DropdownMenuItem(
                            value: prov,
                            child: Text(prov['name'] ?? 'Tanpa Nama'),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProvince = value;
                        selectedCity = null;
                        cities = [];
                      });
                      if (value != null) {
                        _loadCities(value['id'].toString());
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(labelText: 'Pilih Kota'),
                    value:
                        selectedCity != null &&
                                cities.any(
                                  (c) => c['id'] == selectedCity!['id'],
                                )
                            ? cities.firstWhere(
                              (c) => c['id'] == selectedCity!['id'],
                            )
                            : null,
                    items:
                        cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city['name'] ?? 'Tanpa Nama'),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCity = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
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
                        onChanged: (value) => setState(() => isUtama = value),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
