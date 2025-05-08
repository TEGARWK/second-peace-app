import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class OrderDetailShippedPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final String tabStatus;

  const OrderDetailShippedPage({
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

  void _trackPackage(
    BuildContext context,
    String courier,
    String trackingNumber,
  ) async {
    String url;

    if (courier == 'J&T') {
      url = 'https://jet.co.id/track?awb=$trackingNumber';
    } else if (courier == 'JNE') {
      url = 'https://www.jne.co.id/id/tracking/trace?awb=$trackingNumber';
    } else if (courier == 'SiCepat') {
      url = 'https://www.sicepat.com/checkAwb?awb=$trackingNumber';
    } else {
      url = 'https://google.com';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka halaman pelacakan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      order['detail_pesanan'] ?? [],
    );
    final String tanggalPesan = order['tanggal_pesan'] ?? '-';
    final String ekspedisi = order['ekspedisi'] ?? '-';
    final String resi = order['nomor_resi'] ?? '-';
    final String estimasiTiba = order['estimasi_tiba'] ?? '-';
    final double total =
        (order['total_harga'] is num) ? order['total_harga'].toDouble() : 0.0;

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
                  ekspedisi: ekspedisi,
                  resi: resi,
                  estimasiTiba: estimasiTiba,
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
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildShippedNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
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
              "Pesanan sudah dikirim dan sedang dalam perjalanan. Anda dapat melacak status melalui nomor resi.",
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
    required String ekspedisi,
    required String resi,
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
            _infoRow(Icons.person_outline, "Penerima: $penerima"),
            _infoRow(Icons.phone_android, "WhatsApp: $whatsapp"),
            _infoRow(Icons.location_on_outlined, "Alamat: $alamat"),
            _infoRow(Icons.access_time, "Tanggal Pesan: $tanggal"),
            _infoRow(Icons.local_shipping, "Ekspedisi: $ekspedisi"),
            _infoRow(
              Icons.calendar_month_outlined,
              "Estimasi Tiba: $estimasiTiba",
            ),
            const SizedBox(height: 14),
            Center(
              child: Builder(
                builder:
                    (context) => GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: resi));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Nomor resi disalin")),
                        );
                      },
                      child: Column(
                        children: [
                          const Text(
                            "Nomor Resi",
                            style: TextStyle(fontSize: 13, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            resi,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromARGB(221, 243, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
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

  Widget _buildPaymentInfo({required String metode, required String catatan}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.payments_outlined, "Metode: $metode"),
            _infoRow(Icons.edit_note, "Catatan: $catatan"),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final String ekspedisi = order['ekspedisi'] ?? '-';
    final String resi = order['nomor_resi'] ?? '-';
    final double total =
        (order['total_harga'] is num) ? order['total_harga'].toDouble() : 0.0;

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
            icon: const Icon(Icons.location_searching),
            label: const Text("Lacak Paket"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () => _trackPackage(context, ekspedisi, resi),
          ),
        ],
      ),
    );
  }
}
