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
      print('DATA API: $addresses');

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
      print('Result set primary: $result');

      if (result['success'] == true) {
        final addresses = await AuthService().getAddresses();

        // Update state
        setState(() {
          alamatUser = addresses;
        });

        // Cari alamat utama yang baru
        final newPrimary = addresses.firstWhere(
          (alamat) =>
              alamat['utama'] == 1 ||
              alamat['utama'] == '1' ||
              alamat['utama'] == true,
          orElse: () => {},
        );

        print("Alamat utama baru: $newPrimary");

        // Simpan atau kirim balik ke halaman sebelumnya
        Navigator.pop(
          context,
          newPrimary,
        ); // <-- ini agar halaman sebelumnya (checkout) bisa pakai alamat ini

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alamat utama berhasil diperbarui")),
        );
      }
    } catch (e) {
      print("Gagal set utama: $e");
    }
  }

  Future<void> _hapusAlamat(int id, bool isPrimary) async {
    if (isPrimary) {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Konfirmasi'),
              content: const Text(
                'Alamat ini adalah alamat utama. Yakin ingin menghapus?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Hapus'),
                ),
              ],
            ),
      );
      if (confirm != true) return;
    }

    try {
      final result = await AuthService().deleteAddress(id);
      if (result['success'] == true) {
        await _loadAlamatUser();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alamat berhasil dihapus")),
        );
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
      await _loadAlamatUser();
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
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: alamatUser.length,
                      itemBuilder: (context, index) {
                        final alamat = alamatUser[index];
                        final isPrimary =
                            alamat['utama'] == 1 ||
                            alamat['utama'] == '1' ||
                            alamat['utama'] == true;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      alamat['nama'] ?? 'Tanpa Nama',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (!isPrimary && alamatUser.length > 1)
                                          TextButton(
                                            onPressed:
                                                () => _setAsPrimary(
                                                  alamat['id_alamat'],
                                                ),
                                            child: const Text(
                                              'Gunakan',
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                          )
                                        else
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2,
                                            ),
                                            child: Text(
                                              'Digunakan',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        TextButton(
                                          onPressed:
                                              () => _bukaFormAlamat(
                                                existingData: alamat,
                                              ),
                                          child: const Text(
                                            'Edit',
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => _hapusAlamat(
                                                alamat['id_alamat'],
                                                isPrimary,
                                              ),
                                          child: const Text(
                                            'Hapus',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),
                                Text(alamat['alamat'] ?? ''),
                                const SizedBox(height: 4),
                                Text(
                                  'Kota: ${alamat['kota_nama'] ?? '-'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Provinsi: ${alamat['provinsi_nama'] ?? '-'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  alamat['no_whatsapp'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
