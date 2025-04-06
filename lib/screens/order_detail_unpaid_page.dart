import 'package:flutter/material.dart';
import 'package:secondpeacem/data/dummy_products.dart'; // Mengambil data produk
import 'package:secondpeacem/models/product.dart'; // Pastikan Product sudah diimport

class OrderDetailUnpaidPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final String tabStatus;

  const OrderDetailUnpaidPage({
    super.key,
    required this.order,
    required this.tabStatus,
  });

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
    final product = items.isNotEmpty ? items[0] : null;

    // Mengambil produk dari dummyProducts berdasarkan productId
    final productDetails = dummyProducts.firstWhere(
      (prod) => prod.id == product?['productId'],
      orElse:
          () => Product(
            id: 0,
            name: 'Produk Tidak Ditemukan',
            description: '',
            price: 0.0,
            stock: 0,
            size: '',
            imageUrl: 'assets/images/placeholder.png', // Gambar default
          ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          "Pesanan #${order['orderId']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildExpiredInfo(),
                const SizedBox(height: 20),
                _buildSectionTitle("Produk"),
                if (product != null)
                  _buildProductCard(
                    productDetails,
                  ), // Menggunakan productDetails
                const SizedBox(height: 20),
                _buildSectionTitle("Informasi Pesanan"),
                _buildOrderInfoCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildExpiredInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.timer, color: Colors.orange),
          SizedBox(width: 10),
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
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product.imageUrl ?? 'assets/images/placeholder.png',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      width: 70,
                      height: 70,
                      child: const Icon(Icons.image_not_supported),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Produk',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text("Jumlah: ${order['items'][0]['quantity']}"),
                  Text(
                    "Harga: Rp ${product.price}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Alamat Pengiriman"),
            _buildDetailCard([
              "Penerima: ${order['recipientName'] ?? '-'}",
              "No. HP: ${order['recipientPhone'] ?? '-'}",
              "Alamat: ${order['shippingAddress'] ?? '-'}",
            ]),
            const Divider(height: 20), // Added Divider
            _buildSectionTitle("Pengiriman"),
            _buildDetailCard([
              "Kurir: ${order['courier'] ?? '-'}",
              "Estimasi Tiba: ${order['deliveryEstimate'] ?? '-'}",
              "No. Resi: ${order['trackingNumber'] ?? '-'}",
            ]),
            const Divider(height: 20), // Added Divider
            _buildSectionTitle("Pembayaran"),
            _buildDetailCard([
              "Metode: ${order['paymentMethod'] ?? '-'}",
              "Catatan: ${order['note'] ?? 'Tidak ada'}",
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          details
              .map(
                (text) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(text, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            'Rp ${order['total']}',
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

  Widget _buildPayButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // Integrasi Midtrans nanti
        },
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text(
          'Bayar Sekarang',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size.fromHeight(50),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                'Rp ${order['total']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              // Integrasi Checkout
            },
            child: const Text(
              'Bayar Sekarang',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
