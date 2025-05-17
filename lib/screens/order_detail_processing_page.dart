import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailProcessingPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final String tabStatus;

  const OrderDetailProcessingPage({
    super.key,
    required this.order,
    required this.tabStatus,
  });

  double parseToDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String formatCurrency(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String formatDateTime(String? rawDateTime) {
    if (rawDateTime == null || rawDateTime.isEmpty) return '-';
    try {
      final dt = DateTime.parse(rawDateTime);
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items =
        (order['detail_pesanan'] as List).map<Map<String, dynamic>>((e) {
          return Map<String, dynamic>.from(e as Map);
        }).toList();

    final String ekspedisi = order['ekspedisi'] ?? '-';
    final String estimasiTiba = formatDateTime(order['estimasi_tiba'] ?? '');
    final double total = parseToDouble(order['grand_total']);

    final String tanggalPesan = formatDateTime(order['tanggal_pesan'] ?? '');

    final alamatMap = order['alamat'] is Map ? order['alamat'] : {};
    final String alamat = alamatMap['alamat'] ?? '-';
    final String whatsapp = alamatMap['no_whatsapp'] ?? '-';
    final String penerima = alamatMap['nama'] ?? '-';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          "Pesanan #${order['id_pesanan'] ?? '-'}",
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
                _buildProcessingNotice(),
                const SizedBox(height: 12),
                _buildSectionTitle("🧾 Daftar Produk"),
                ...items.map((item) => _buildProductItem(item)).toList(),
                const SizedBox(height: 20),
                _buildSectionTitle("📦 Informasi Pengiriman"),
                _buildShippingInfo(
                  penerima: penerima,
                  alamat: alamat,
                  whatsapp: whatsapp,
                  tanggal: tanggalPesan,
                  ekspedisi: ekspedisi,
                  estimasiTiba: estimasiTiba,
                ),

                const SizedBox(height: 20),
                _buildSectionTitle("💳 Informasi Pembayaran"),
                _buildPaymentInfo(
                  metode: order['metode_pembayaran'] ?? 'Transfer Bank',
                ),
              ],
            ),
          ),
          _buildBottomBar(total),
        ],
      ),
    );
  }

  Widget _buildProcessingNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.local_shipping_outlined, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Pesanan Anda sedang diproses dan akan segera dikirim. Mohon ditunggu ya!",
              style: TextStyle(color: Colors.blue, fontSize: 13),
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

  Widget _buildProductItem(Map<String, dynamic> item) {
    final produk = item['produk'] ?? {};
    final nama =
        produk is Map
            ? (produk['nama_produk'] ?? 'Produk tidak ditemukan')
            : 'Produk tidak ditemukan';
    final jumlah = item['jumlah'] ?? 0;
    final harga = parseToDouble(produk['harga']);

    final ukuran = produk['size'] ?? '-';
    const baseUrl = 'https://secondpeace.my.id/uploads/';
    final gambar = produk['gambar'] ?? '';
    final fullImageUrl = gambar.isNotEmpty ? '$baseUrl$gambar' : '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  fullImageUrl.isNotEmpty
                      ? Image.network(
                        fullImageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                      )
                      : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Jumlah: $jumlah"),
                  Text("Ukuran: $ukuran"),
                  Text(
                    "Harga: ${formatCurrency(harga)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
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

  Widget _buildShippingInfo({
    required String penerima,
    required String alamat,
    required String whatsapp,
    required String tanggal,
    required String ekspedisi,
    required String estimasiTiba,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 8),
                Text("Penerima: $penerima"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone_android),
                const SizedBox(width: 8),
                Text("WhatsApp: $whatsapp"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined),
                const SizedBox(width: 8),
                Flexible(child: Text("Alamat: $alamat")),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text("Tanggal Pesan: $tanggal"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.local_shipping),
                const SizedBox(width: 8),
                Text("Ekspedisi: $ekspedisi"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined),
                const SizedBox(width: 8),
                Text("Estimasi Tiba: $estimasiTiba"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo({required String metode}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payments_outlined),
                const SizedBox(width: 8),
                Text("Metode: $metode"),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(double total) {
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
                'Total Pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                formatCurrency(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.chat),
            label: const Text("Chat Toko"),
            style: ElevatedButton.styleFrom(
              iconColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
              foregroundColor: Colors.white,
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              // TODO: Implementasi fitur chat
            },
          ),
        ],
      ),
    );
  }
}
