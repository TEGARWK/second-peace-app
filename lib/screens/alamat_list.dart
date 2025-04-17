import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'alamat_pengiriman_page.dart';

class DaftarAlamatPage extends StatefulWidget {
  const DaftarAlamatPage({super.key});

  @override
  State<DaftarAlamatPage> createState() => _DaftarAlamatPageState();
}

class _DaftarAlamatPageState extends State<DaftarAlamatPage> {
  List<Map<String, dynamic>> alamatUser = [];

  @override
  void initState() {
    super.initState();
    _loadAlamatUser();
  }

  Future<void> _loadAlamatUser() async {
    try {
      final addresses = await AuthService().getAddresses();
      setState(() {
        alamatUser = addresses;
      });
    } catch (e) {
      print('Gagal memuat alamat: $e');
      setState(() {
        alamatUser = [];
      });
    }
  }

  Future<void> _setAsPrimary(int id) async {
    try {
      final result = await AuthService().setPrimaryAddress(id);
      if (result['success'] == true) {
        // Ambil alamat terbaru setelah update
        final newList = await AuthService().getAddresses();
        final primary = newList.firstWhere(
          (a) => a['utama'] == true,
          orElse: () => {},
        );

        // Kirim balik ke halaman sebelumnya (CheckoutPage)
        Navigator.pop(context, primary);
      }
    } catch (e) {
      print("Gagal set utama: $e");
    }
  }

  Future<void> _hapusAlamat(int id) async {
    try {
      final result = await AuthService().deleteAddress(id);
      print("DELETE RESPONSE: $result");
      if (result['success'] == true) {
        _loadAlamatUser();
      }
    } catch (e) {
      print("Gagal hapus alamat: $e");
    }
  }

  Future<void> _bukaFormAlamat({Map<String, dynamic>? existingData}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlamatPengirimanPage(existingData: existingData),
      ),
    );
    if (result == true) {
      _loadAlamatUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Alamat',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body:
          alamatUser.isEmpty
              ? const Center(child: Text("Belum ada alamat."))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: alamatUser.length,
                itemBuilder: (context, index) {
                  final alamat = alamatUser[index];
                  final isPrimary = alamat['utama'] == true;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Nama dan Label Utama
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    alamat['nama'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isPrimary)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Utama',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, alamat);
                                },
                                child: const Text(
                                  'Gunakan',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${alamat['alamat']}, ${alamat['kota']} ${alamat['kodePos']}',
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                alamat['telepon'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  if (!isPrimary)
                                    TextButton(
                                      onPressed:
                                          () => _setAsPrimary(alamat['id']),
                                      child: const Text(
                                        'Set Utama',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                  TextButton(
                                    onPressed:
                                        () => _bukaFormAlamat(
                                          existingData: alamat,
                                        ),
                                    child: const Text(
                                      'Edit',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _hapusAlamat(alamat['id']),
                                    child: const Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () => _bukaFormAlamat(),
        label: const Text(
          'Tambah Alamat',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
      ),
    );
  }
}
