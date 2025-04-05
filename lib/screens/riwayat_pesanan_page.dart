import 'package:flutter/material.dart';

class RiwayatPesananPage extends StatelessWidget {
  const RiwayatPesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: const Center(
        child: Text('Halaman Riwayat Pesanan', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
