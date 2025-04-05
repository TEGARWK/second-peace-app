import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailShippedPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final String tabStatus;

  const OrderDetailShippedPage({
    super.key,
    required this.order,
    required this.tabStatus,
  });

  void _trackPackage(String courier, String trackingNumber) async {
    String url = '';

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
      throw 'Tidak bisa membuka $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Detail Pesanan #${order['id']}',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Pesanan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.local_shipping, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pesanan sedang dalam perjalanan ke alamat tujuan.',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Produk info
            const Text(
              'Produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
                title: const Text('Nama Produk'),
                subtitle: const Text('Jumlah: 1'),
                trailing: const Text(
                  'Rp 250.000',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pengiriman & Metode Pembayaran
            const Text(
              'Pengiriman',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kurir: J&T Express (2-4 hari)',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),

            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Transfer Bank - BCA',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    () => _trackPackage(
                      order['courier'],
                      order['trackingNumber'],
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Lacak Paket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
