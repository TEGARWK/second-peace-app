import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/dummy_accounts.dart';
import 'alamat_pengiriman_page.dart';

class DaftarAlamatPage extends StatefulWidget {
  const DaftarAlamatPage({super.key});

  @override
  State<DaftarAlamatPage> createState() => _DaftarAlamatPageState();
}

class _DaftarAlamatPageState extends State<DaftarAlamatPage> {
  List<Map<String, dynamic>> alamatUser = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadAlamatUser();
  }

  Future<void> _loadAlamatUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');

    if (userId != null) {
      final user = dummyAccounts.firstWhere(
        (acc) => acc['id'] == userId,
        orElse: () => {},
      );

      setState(() {
        alamatUser = List<Map<String, dynamic>>.from(user['addresses'] ?? []);
      });
    }
  }

  void _setAsPrimary(int index) async {
    setState(() {
      for (var i = 0; i < alamatUser.length; i++) {
        alamatUser[i]['isPrimary'] = (i == index);
      }
    });

    if (userId != null) {
      final user = dummyAccounts.firstWhere((u) => u['id'] == userId);
      user['addresses'] = alamatUser;
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
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body:
          alamatUser.isEmpty
              ? const Center(child: Text("Belum ada alamat."))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: alamatUser.length,
                itemBuilder: (context, index) {
                  final alamat = alamatUser[index];
                  final isPrimary = alamat['isPrimary'] == true;

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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    alamat['label'],
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
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(alamat['address']),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Alamat ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              if (isPrimary)
                                const Text(
                                  'Alamat Utama',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                              Row(
                                children: [
                                  if (!isPrimary)
                                    TextButton(
                                      onPressed: () => _setAsPrimary(index),
                                      child: const Text(
                                        'Set Utama',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                                  const AlamatPengirimanPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Edit',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        alamatUser.removeAt(index);
                                      });
                                    },
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
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AlamatPengirimanPage()),
          );
        },
        label: const Text(
          'Tambah Alamat',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
      ),
    );
  }
}
