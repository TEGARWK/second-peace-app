import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailReceivedPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailReceivedPage({super.key, required this.order});

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

  String formatDateTime(String? raw) {
    try {
      if (raw == null) return '-';
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return raw ?? '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      order['detail_pesanan'] ?? [],
    );
    final alamat = order['alamat'] ?? {};
    final totalHarga = order['grand_total'];
    final tanggalDiterima = order['tanggal_diterima'];
    final ekspedisi = order['ekspedisi'] ?? '-';
    final resi = order['nomor_resi'] ?? '-';

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
                _buildSuccessNotice(),
                const SizedBox(height: 20),
                _buildSectionTitle("🧾 Daftar Produk"),
                ...items.map(_buildProductItem).toList(),
                const SizedBox(height: 20),
                _buildSectionTitle("📦 Informasi Pengiriman"),
                _buildShippingInfo(
                  penerima: alamat['nama'] ?? '-',
                  alamatLengkap: alamat['alamat'] ?? '-',
                  whatsapp: alamat['no_whatsapp'] ?? '-',
                  tanggal: formatDateTime(order['tanggal_pesan']),
                  ekspedisi: ekspedisi,
                  resi: resi,
                  tanggalDiterima: formatDateTime(tanggalDiterima),
                ),
              ],
            ),
          ),
          _buildBottomBar(totalHarga),
        ],
      ),
    );
  }

  Widget _buildSuccessNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle_outline, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pesanan telah diterima. Terima kasih telah berbelanja!',
              style: TextStyle(color: Colors.green, fontSize: 13),
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
    final nama = produk['nama_produk'] ?? 'Produk tidak ditemukan';
    final gambar = produk['gambar'] ?? '';
    final harga = parseToDouble(produk['harga']);
    final jumlah = item['jumlah'] ?? 0;

    const baseUrl = 'https://secondpeace.my.id/uploads/';
    final fullImageUrl = gambar.isNotEmpty ? '$baseUrl$gambar' : '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
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
                            (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 70),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Jumlah: $jumlah"),
                  Text(
                    "Harga: ${formatCurrency(harga)}",
                    style: const TextStyle(
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

  Widget _buildShippingInfo({
    required String penerima,
    required String alamatLengkap,
    required String whatsapp,
    required String tanggal,
    required String ekspedisi,
    required String resi,
    required String tanggalDiterima,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.person_outline, "Penerima: $penerima"),
            _infoRow(Icons.phone, "WhatsApp: $whatsapp"),
            _infoRow(Icons.location_on_outlined, "Alamat: $alamatLengkap"),
            _infoRow(Icons.access_time, "Tanggal Pesan: $tanggal"),
            _infoRow(Icons.local_shipping, "Ekspedisi: $ekspedisi"),
            _infoRow(Icons.confirmation_number, "Resi: $resi"),
            const Divider(height: 20),
            _infoRow(Icons.check_circle, "Tanggal Diterima: $tanggalDiterima"),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(dynamic totalHarga) {
    final double total = parseToDouble(totalHarga);

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
            icon: const Icon(Icons.reviews_outlined),
            label: const Text("Beri Ulasan"),
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
              // TODO: navigasi ke halaman ulasan
            },
          ),
        ],
      ),
    );
  }
}
