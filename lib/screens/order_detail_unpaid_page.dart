import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailUnpaidPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final String tabStatus;

  Future<void> cancelOrder(BuildContext context, int idPesanan) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autentikasi gagal. Silakan login kembali.'),
        ),
      );
      return;
    }

    final uri = Uri.parse(
      'https://yourdomain.com/api/pesanan/$idPesanan/cancel',
    ); // Ganti URL sesuai route
    try {
      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibatalkan')),
        );
        Navigator.pop(context); // kembali ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membatalkan pesanan')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  const OrderDetailUnpaidPage({
    super.key,
    required this.order,
    required this.tabStatus,
  });

  String formatCurrency(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String formatDateTime(String rawDateTime) {
    try {
      final dt = DateTime.parse(rawDateTime);
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return rawDateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      order['detail_pesanan'] ?? [],
    );
    final String tanggalPesan = order['tanggal_pesan'] ?? '-';
    final String expiredAt = order['expired_at'] ?? '';
    final double total =
        (order['total_harga'] is num)
            ? order['total_harga'].toDouble()
            : double.tryParse(order['total_harga'].toString()) ?? 0.0;

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
                _buildAntrianNotice(expiredAt),
                const SizedBox(height: 12),
                _buildSectionTitle("🧾 Daftar Produk"),
                ...items.map((item) => _buildProductItem(item)).toList(),
                const SizedBox(height: 20),
                _buildSectionTitle("📦 Informasi Pengiriman"),
                _buildShippingInfo(
                  penerima: order['penerima'] ?? '-',
                  alamat: order['alamat'] ?? '-',
                  whatsapp: order['no_whatsapp'] ?? '-',
                  tanggal: tanggalPesan,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("💳 Informasi Pembayaran"),
                _buildPaymentInfo(
                  metode: order['metode_pembayaran'] ?? 'Transfer Bank',
                  catatan: order['catatan'] ?? 'Tidak ada',
                ),
              ],
            ),
          ),
          _buildBottomBar(total, context),
        ],
      ),
    );
  }

  Widget _buildAntrianNotice(String expiredAt) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber, color: Colors.red),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Karena ini produk preloved, hanya tersedia 1 item. Siapa yang membayar lebih dulu akan mendapatkannya.",
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                "Batas bayar: ${formatDateTime(expiredAt)}",
                style: const TextStyle(fontSize: 13, color: Colors.red),
              ),
            ],
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
    final nama = item['nama_produk'] ?? '-';
    final jumlah = item['jumlah'] ?? 0;
    final harga = item['harga'] ?? 0;
    final ukuran = item['ukuran'] ?? '-';
    final gambar = item['gambar'] ?? '';

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
                  gambar.isNotEmpty
                      ? Image.network(
                        gambar,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
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
                        child: const Icon(Icons.image),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo({required String metode, required String catatan}) {
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
            Row(
              children: [
                const Icon(Icons.edit_note),
                const SizedBox(width: 8),
                Text("Catatan: $catatan"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(double total, BuildContext context) {
    final String paymentUrl = order['payment_url'] ?? '';
    final int idPesanan = order['id_pesanan'] ?? 0;

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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => cancelOrder(context, idPesanan),

                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: const Text(
                    "Batalkan Pesanan",
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () async {
                    if (paymentUrl.isNotEmpty &&
                        await canLaunchUrl(Uri.parse(paymentUrl))) {
                      await launchUrl(
                        Uri.parse(paymentUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Link pembayaran tidak tersedia atau gagal dibuka',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Bayar Sekarang',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
