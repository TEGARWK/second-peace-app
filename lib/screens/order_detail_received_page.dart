import 'package:flutter/material.dart';

class OrderDetailReceivedPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailReceivedPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pesanan #${order['id'] ?? '-'}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Produk'),
            _buildProductCard(order['product'] ?? {}),
            const SizedBox(height: 20),
            _buildDetailCard('Rincian Pengiriman', [
              "Kurir: ${order['courier'] ?? '-'}",
              "No. Resi: ${order['resi'] ?? '-'}",
            ]),
            const SizedBox(height: 20),
            _buildDetailCard('Metode Pembayaran', [
              order['paymentMethod'] ?? '-',
            ]),
            const SizedBox(height: 20),
            _buildDetailCard('Tanggal Diterima', [
              order['receivedDate'] ?? '-',
            ]),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Beli Lagi",
                style: TextStyle(color: Colors.white),
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Lihat Ulasan",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product['image'] ?? 'assets/images/placeholder.png',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Produk',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Harga: ${product['price'] ?? 'Rp 0'}",
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<String> details) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...details
                .where((detail) => detail.isNotEmpty)
                .map(
                  (detail) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(detail, style: const TextStyle(fontSize: 14)),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
