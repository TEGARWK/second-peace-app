import 'package:flutter/material.dart';

class OrderDetailUnpaidPage extends StatelessWidget {
  final Map<String, String> order;
  final String tabStatus; // Tambahkan ini

  const OrderDetailUnpaidPage({
    super.key,
    required this.order,
    required this.tabStatus, // Tambahkan ini
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Detail Pesanan #${order['id']}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpiredInfo(),
            const SizedBox(height: 20),
            _buildSectionTitle('Produk'),
            _buildProductCard(order['product'] as Map<String, dynamic>? ?? {}),
            const SizedBox(height: 20),
            _buildSectionTitle('Rincian Pengiriman'),
            _buildDetailCard([
              "Kurir: ${order['courier']}",
              "Estimasi: ${order['deliveryEstimate']}",
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('Metode Pembayaran'),
            _buildDetailCard([order['paymentMethod'] ?? 'Tidak tersedia']),
            const SizedBox(height: 20),
            _buildTotalPayment(order['total'] ?? 'Rp 0'),
            const SizedBox(height: 24),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiredInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Icon(Icons.timer, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bayar sebelum 22 Mar 2025 23:59 WIB. Jika lewat waktu ini, pesanan akan otomatis dibatalkan.',
              style: TextStyle(color: Colors.orange, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
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
                    "Jumlah: ${product['quantity']}",
                    style: const TextStyle(fontSize: 14),
                  ),
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

  Widget _buildDetailCard(List<String> details) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              details
                  .map(
                    (detail) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(detail, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildTotalPayment(String total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Pembayaran:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            total,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Arahkan ke Midtrans
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Bayar Sekarang',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
