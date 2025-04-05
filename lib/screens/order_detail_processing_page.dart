import 'package:flutter/material.dart';

class OrderDetailProcessingPage extends StatelessWidget {
  final Map<String, dynamic> order;
  final String tabStatus;

  const OrderDetailProcessingPage({
    super.key,
    required this.order,
    required this.tabStatus,
  });

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
                color: Colors.purple[50],
                border: Border.all(color: Colors.purple),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.timelapse, color: Colors.purple),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pesanan sedang diproses oleh penjual. Mohon ditunggu ya!',
                      style: TextStyle(color: Colors.purple, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Informasi Penerima
            const Text(
              'Informasi Penerima',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${order['receiverName']} \n${order['receiverPhone']} \n${order['receiverAddress']}',
              style: const TextStyle(color: Colors.black54),
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
                title: Text(order['productName'] ?? 'Nama Produk'),
                subtitle: Text('Jumlah: ${order['quantity'] ?? 1}'),
                trailing: Text(
                  'Rp ${order['price'] ?? '0'}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pengiriman
            const Text(
              'Pengiriman',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Kurir: ${order['courier']} (Estimasi: ${order['deliveryEstimate']})',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),

            // Metode Pembayaran
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              order['paymentMethod'] ?? 'Transfer Bank - BCA',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Total Pembayaran
            const Text(
              'Total Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Rp ${order['totalPayment'] ?? '0'}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
