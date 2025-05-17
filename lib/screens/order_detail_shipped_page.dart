import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailShippedPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailShippedPage({Key? key, required this.order})
    : super(key: key);

  String formatCurrency(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  double parseToDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String formatDateTime(String rawDateTime) {
    try {
      final dt = DateTime.parse(rawDateTime);
      return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(dt);
    } catch (_) {
      return rawDateTime;
    }
  }

  Future<void> _markAsReceived(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Autentikasi gagal')));
      return;
    }

    final response = await http.patch(
      Uri.parse(
        'https://secondpeace.my.id/api/v1/pesanan/${order['id_pesanan']}/mark-received',
      ),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan ditandai sebagai selesai')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui status pesanan')),
      );
    }
  }

  String _getTrackingUrl(String ekspedisi, String resi) {
    switch (ekspedisi.toLowerCase()) {
      case 'jne':
        return 'https://www.jne.co.id/id/tracking/trace/$resi';
      case 'j&t':
        return 'https://www.jet.co.id/track?awb=$resi';
      case 'sicepat':
        return 'https://www.sicepat.com/checkAwb?awb=$resi';
      default:
        return 'https://google.com/search?q=cek+resi+$resi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items =
        (order['detail_pesanan'] as List).map<Map<String, dynamic>>((e) {
          return Map<String, dynamic>.from(e as Map);
        }).toList();

    final alamat = order['alamat'] is Map ? order['alamat'] : {};
    final tanggalPesan = order['tanggal_pesan'] ?? '-';
    final ekspedisi = order['ekspedisi'] ?? '-';
    final resi = order['nomor_resi'] ?? '-';
    final estimasiTiba = order['estimasi_tiba'] ?? '-';

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
                _buildShippedNotice(),
                const SizedBox(height: 20),
                _buildSectionTitle("🧾 Daftar Produk"),
                ...items.map(_buildProductItem).toList(),
                const SizedBox(height: 20),
                _buildSectionTitle("📦 Informasi Pengiriman"),
                _buildShippingInfo(
                  context,
                  penerima: alamat['nama'] ?? '-',
                  alamatLengkap: alamat['alamat'] ?? '-',
                  whatsapp: alamat['no_whatsapp'] ?? '-',
                  tanggal: tanggalPesan,
                  ekspedisi: ekspedisi,
                  estimasiTiba: estimasiTiba,
                  resi: resi,
                ),
              ],
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildShippedNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: const [
          Icon(Icons.local_shipping, color: Colors.purple),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pesanan sudah dikirim dan sedang dalam perjalanan. Tekan tombol di bawah jika pesanan sudah diterima.',
              style: TextStyle(color: Colors.purple, fontSize: 13),
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
    final jumlah = item['jumlah'] ?? 0;
    final harga = parseToDouble(produk['harga']);
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

  Widget _buildShippingInfo(
    BuildContext context, {
    required String penerima,
    required String alamatLengkap,
    required String whatsapp,
    required String tanggal,
    required String ekspedisi,
    required String estimasiTiba,
    required String resi,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.person, "Penerima: $penerima"),
            _infoRow(Icons.phone_android, "WhatsApp: $whatsapp"),
            _infoRow(Icons.location_on_outlined, "Alamat: $alamatLengkap"),
            _infoRow(Icons.access_time, "Tanggal Pesan: $tanggal"),
            _infoRow(Icons.local_shipping, "Ekspedisi: $ekspedisi"),
            _infoRow(Icons.calendar_month, "Estimasi Tiba: $estimasiTiba"),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Resi: $resi",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: resi));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Nomor resi disalin!"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.travel_explore_outlined, size: 18),
              style: ElevatedButton.styleFrom(
                iconColor: Colors.white,
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 40),
              ),
              label: const Text(
                "Lacak Pengiriman",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              onPressed: () async {
                final trackingUrl = _getTrackingUrl(ekspedisi, resi);
                if (await canLaunch(trackingUrl)) {
                  await launch(trackingUrl);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tidak dapat membuka halaman pelacakan"),
                    ),
                  );
                }
              },
            ),
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

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle_outline),
        label: const Text(
          "Pesanan Diterima",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          iconColor: Colors.white,
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () => _markAsReceived(context),
      ),
    );
  }
}
