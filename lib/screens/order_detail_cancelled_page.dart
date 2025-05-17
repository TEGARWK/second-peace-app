import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailCancelledPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailCancelledPage({super.key, required this.order});

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

  String formatDate(String? rawDateTime) {
    try {
      if (rawDateTime == null) return '-';
      final dt = DateTime.parse(rawDateTime);
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return rawDateTime ?? '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      order['detail_pesanan'] ?? [],
    );
    final double total = parseToDouble(order['grand_total']);

    final String tanggalPesan = order['tanggal'] ?? '-';
    final String status = order['status_pesanan'] ?? 'Pesanan Dibatalkan';
    final String tanggalExpired = formatDate(order['expired_at']);

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCancelledNotice(),
          const SizedBox(height: 20),
          _buildSectionTitle("🧾 Daftar Produk"),
          ...items.map(_buildProductItem).toList(),
          const SizedBox(height: 20),
          _buildSectionTitle("📋 Rincian Pesanan"),
          _buildInfoCard([
            _infoRow(Icons.info_outline, "Status", status),
            _infoRow(
              Icons.calendar_today,
              "Tanggal Pesan",
              formatDate(tanggalPesan),
            ),
            _infoRow(
              Icons.cancel_schedule_send_outlined,
              "Tanggal Expired",
              tanggalExpired,
            ),

            _infoRow(Icons.attach_money, "Total", formatCurrency(total)),
          ]),
        ],
      ),
    );
  }

  Widget _buildCancelledNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.cancel_outlined, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Pesanan ini telah dibatalkan. Silakan hubungi admin jika ada kendala lebih lanjut.",
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    final produk = item['produk'] ?? {};
    final nama = produk['nama_produk'] ?? 'Produk tidak ditemukan';
    final jumlah = item['jumlah'] ?? 0;
    final harga = parseToDouble(produk['harga']);

    final ukuran = produk['size'] ?? '-';
    final gambar = produk['gambar'] ?? '';
    const baseUrl = 'https://secondpeace.my.id/uploads/';
    final fullImageUrl = gambar.isNotEmpty ? '$baseUrl$gambar' : '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Jumlah: $jumlah"),
                  Text("Ukuran: $ukuran"),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$label: ",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
