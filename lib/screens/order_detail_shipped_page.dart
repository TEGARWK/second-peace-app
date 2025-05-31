import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:secondpeacem/services/shipping_service.dart';

class OrderDetailShippedPage extends StatefulWidget {
  final int idPesanan;
  const OrderDetailShippedPage({super.key, required this.idPesanan});

  @override
  State<OrderDetailShippedPage> createState() => _OrderDetailShippedPageState();
}

class _OrderDetailShippedPageState extends State<OrderDetailShippedPage> {
  Map<String, dynamic>? order;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/v1/pesanan/${widget.idPesanan}'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = Map<String, dynamic>.from(jsonDecode(response.body));
      setState(() {
        order = data['pesanan'];
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat detail pesanan')),
      );
    }
  }

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
      return rawDateTime;
    }
  }

  Future<void> _markAsReceived() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.patch(
      Uri.parse(
        'http://10.0.2.2:8000/api/v1/pesanan/${widget.idPesanan}/mark-received',
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

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (order == null) {
      return const Scaffold(
        body: Center(child: Text('Data pesanan tidak ditemukan')),
      );
    }

    final List<Map<String, dynamic>> items =
        (order!['detail_pesanan'] as List?)
            ?.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList() ??
        [];
    final alamat = order!['alamat'] ?? {};
    final tanggalPesan = formatDateTime(order!['tanggal_pesan']);
    final ekspedisi = order!['ekspedisi'] ?? '-';
    final resi = order!['nomor_resi'] ?? '-';
    final estimasiTiba = formatDateTime(order!['estimasi_tiba']);
    final double total = parseToDouble(order!['grand_total']);
    final double ongkir = parseToDouble(order!['ongkir']);
    final double subtotal = total - ongkir;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Pesanan #${order!['id_pesanan'] ?? '-'}"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotice(),
          const SizedBox(height: 12),
          _buildSectionTitle("🧾 Daftar Produk"),
          ...items.map(_buildProductItem).toList(),
          const SizedBox(height: 20),
          _buildSectionTitle("📨 Info Penerima"),
          _buildRecipientInfo(
            penerima: alamat['nama'] ?? '-',
            alamat: alamat['alamat'] ?? '-',
            whatsapp: alamat['no_whatsapp'] ?? '-',
            kota: alamat['kota_nama'] ?? '-',
            provinsi: alamat['provinsi_nama'] ?? '-',
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("🚚 Info Pengiriman"),
          _buildShippingInfo(
            tanggal: tanggalPesan,
            ekspedisi: ekspedisi,
            estimasiTiba: estimasiTiba,
            resi: resi,
          ),
          const SizedBox(height: 20),
          _buildRingkasanPembayaran(
            subtotal: subtotal,
            ongkir: ongkir,
            total: total,
          ),
          const SizedBox(height: 20),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text("Pesanan Diterima"),
          onPressed: _markAsReceived,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotice() {
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
              "Pesanan kamu sedang dikirim. Lacak resi untuk melihat posisi terkini pengiriman. Jika semua sudah diterima, silakan tekan tombol 'Pesanan Diterima' di bawah.",
              style: TextStyle(color: Colors.purple, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  Widget _buildProductItem(Map<String, dynamic> item) {
    final produk = item['produk'] ?? {};
    final nama = produk['nama_produk'] ?? 'Produk tidak ditemukan';
    final jumlah = item['jumlah'] ?? 0;
    final harga = parseToDouble(produk['harga']);
    final gambar = produk['gambar'] ?? '';
    final fullImageUrl =
        gambar.isNotEmpty ? 'https://secondpeace.my.id/uploads/$gambar' : '';

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
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
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

  Widget _buildRecipientInfo({
    required String penerima,
    required String alamat,
    required String whatsapp,
    required String kota,
    required String provinsi,
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
                const Icon(Icons.map_outlined),
                const SizedBox(width: 8),
                Text("Kota: $kota"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.public_outlined),
                const SizedBox(width: 8),
                Text("Provinsi: $provinsi"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingInfo({
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
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.confirmation_number_outlined),
                const SizedBox(width: 8),
                Text("Resi: $resi"),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (_) => const Center(child: CircularProgressIndicator()),
                  );

                  final tracking = await ShippingService().trackResi(
                    ekspedisi: ekspedisi.toLowerCase(),
                    resi: resi,
                  );

                  Navigator.pop(context); // tutup dialog loading

                  // tampilkan detail tracking dengan dialog sederhana
                  showDialog(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text("Status Pengiriman"),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Status: ${tracking['status']}"),
                                const SizedBox(height: 8),
                                const Text("Riwayat:"),
                                ...List.from(
                                  tracking['history'] ?? [],
                                ).map<Widget>((item) {
                                  return Text(
                                    "- ${item['date']} | ${item['desc']}",
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Tutup"),
                            ),
                          ],
                        ),
                  );
                } catch (e) {
                  Navigator.pop(context); // pastikan dialog ditutup
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal melacak resi: $e')),
                  );
                }
              },
              child: const Text(
                "Lacak Pengiriman",
                style: TextStyle(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
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
}
