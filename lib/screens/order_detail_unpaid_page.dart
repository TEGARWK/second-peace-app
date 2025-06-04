// Revisi: order_detail_unpaid_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String _formatDateTime(String rawDateTime) {
  try {
    final dt = DateTime.parse(rawDateTime);
    return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(dt);
  } catch (_) {
    return rawDateTime;
  }
}

class OrderDetailUnpaidPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final String tabStatus;

  const OrderDetailUnpaidPage({
    super.key,
    required this.order,
    required this.tabStatus,
  });

  // Util konversi
  double parseToDouble(dynamic value) {
    return (value is num)
        ? value.toDouble()
        : double.tryParse(value.toString()) ?? 0.0;
  }

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
      'https://secondpeace.my.id/api/v1/pesanan/$idPesanan/cancel',
    );
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
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membatalkan pesanan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

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
    final String tanggalPesan = order['tanggal'] ?? '-';
    final String expiredAt = order['expired_at'] ?? '';
    final double total = parseToDouble(order['grand_total']);
    final double ongkir = parseToDouble(order['ongkir']);
    final double subtotalProduk = total - ongkir;

    final alamatData = order['alamat'] ?? {};
    final String alamatLengkap = alamatData['alamat'] ?? '-';
    final String penerima = alamatData['nama'] ?? '-';
    final String whatsapp = alamatData['no_whatsapp'] ?? '-';

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
                  penerima: penerima,
                  alamat: alamatLengkap,
                  whatsapp: whatsapp,
                  tanggal: tanggalPesan,
                ),
                const SizedBox(height: 20),
                _buildRingkasanPembayaran(
                  subtotal: subtotalProduk,
                  ongkir: ongkir,
                  total: total,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("💳 Informasi Pembayaran"),
                _buildPaymentInfo(
                  metode: order['metode_pembayaran'] ?? 'Transfer Bank',
                ),
              ],
            ),
          ),
          _buildBottomBar(total, context, order),
        ],
      ),
    );
  }

  Widget _buildAntrianNotice(String expiredAt) => Container(
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
                "Karena ini produk preloved...",
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
              "Batas bayar: ${_formatDateTime(expiredAt)}",

              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  );

  Widget _buildProductItem(Map<String, dynamic> item) {
    final produk = item['produk'] ?? {};
    final nama =
        produk.isEmpty ? 'Produk telah dihapus' : produk['nama_produk'] ?? '-';
    final jumlah = item['jumlah'] ?? 0;
    final harga = parseToDouble(produk['harga']);
    final ukuran = produk['size'] ?? '-';
    final gambar = produk['gambar'] ?? '';
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
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
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
                Flexible(child: Flexible(child: Text("Alamat: $alamat"))),
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

  Widget _buildRingkasanPembayaran({
    required double subtotal,
    required double ongkir,
    required double total,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🧮 Ringkasan Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal Produk"),
                Text(formatCurrency(subtotal)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text("Ongkir"), Text(formatCurrency(ongkir))],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total"),
                Text(
                  formatCurrency(total),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo({required String metode}) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined),
          const SizedBox(width: 8),
          Text("Metode: $metode"),
        ],
      ),
    ),
  );

  Widget _buildBottomBar(
    double total,
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    final snapToken = order['snap_token'];
    final orderId = order['id_pembayaran'];
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
                  onPressed: () {
                    if (snapToken != null && orderId != null) {
                      Navigator.pushNamed(
                        context,
                        '/snap',
                        arguments: {
                          'snap_token': snapToken,
                          'order_id': orderId,
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Snap token tidak ditemukan'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 45),
                  ),
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
