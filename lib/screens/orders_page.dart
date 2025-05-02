import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'order_detail_unpaid_page.dart';
import 'order_detail_processing_page.dart';
import 'order_detail_shipped_page.dart';
import 'order_detail_received_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> unpaid = [];
  List<Map<String, dynamic>> processing = [];
  List<Map<String, dynamic>> shipped = [];
  List<Map<String, dynamic>> received = [];

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  Future<void> _loadUserOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');

    if (token == null || userId == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/pesanan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List orders = data['pesanan'];

        setState(() {
          unpaid =
              orders
                  .where((o) => o['status_pesanan'] == 'Menunggu Pembayaran')
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();

          processing =
              orders
                  .where((o) => o['status_pesanan'] == 'Pembayaran Diterima')
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();

          shipped =
              orders
                  .where((o) => o['status_pesanan'] == 'Dikirim')
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();

          received =
              orders
                  .where((o) => o['status_pesanan'] == 'Selesai')
                  .map<Map<String, dynamic>>(
                    (e) => Map<String, dynamic>.from(e),
                  )
                  .toList();
        });
      } else {
        print('Gagal memuat pesanan: ${response.body}');
      }
    } catch (e) {
      print('❌ Error memuat pesanan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          title: const Text(
            'Pesanan Saya',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: Colors.white,
              child: const TabBar(
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                indicatorWeight: 2.5,
                labelStyle: TextStyle(fontWeight: FontWeight.w600),
                tabs: [
                  Tab(
                    icon: Icon(Icons.payments_outlined),
                    child: Text('Belum Bayar', style: TextStyle(fontSize: 12)),
                  ),
                  Tab(
                    icon: Icon(Icons.inventory_2_outlined),
                    child: Text('Diproses', style: TextStyle(fontSize: 12)),
                  ),
                  Tab(
                    icon: Icon(Icons.local_shipping_outlined),
                    child: Text('Dikirim', style: TextStyle(fontSize: 12)),
                  ),
                  Tab(
                    icon: Icon(Icons.check_circle_outline),
                    child: Text('Selesai', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(unpaid, 'Belum Bayar'),
            _buildOrderList(processing, 'Diproses'),
            _buildOrderList(shipped, 'Dikirim'),
            _buildOrderList(received, 'Selesai'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders, String status) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada pesanan.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final items =
              (order['detail_pesanan'] is List)
                  ? List<Map<String, dynamic>>.from(order['detail_pesanan'])
                  : [];

          final createdAt = order['created_at'] ?? '';
          String formattedDate = '-';
          try {
            final date = DateTime.parse(createdAt);
            formattedDate = DateFormat(
              'd MMMM yyyy, HH:mm',
              'id_ID',
            ).format(date);
            print("📅 formattedDate: $formattedDate"); // debug
          } catch (e) {
            print("⚠️ Gagal format tanggal: $e");
          }

          final firstItem = items.isNotEmpty ? items[0] : null;
          final additionalCount = (items.length - 1).clamp(0, items.length);
          final totalItems = items.fold<int>(0, (sum, item) {
            final qty = item['jumlah'];
            final parsedQty =
                qty is String ? int.tryParse(qty) ?? 0 : (qty as num).toInt();
            return sum + parsedQty;
          });

          final totalHarga = items.fold<num>(0, (sum, item) {
            final harga = item['total_harga'];
            final parsedHarga =
                harga is String ? num.tryParse(harga) ?? 0 : harga;
            return sum + parsedHarga;
          });

          return GestureDetector(
            onTap: () => _navigateToDetailPage(order, status),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "🛒 ${order['id_pembayaran'] ?? '-'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "📅 $formattedDate",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const Divider(height: 20),
                    if (firstItem != null)
                      Text(
                        "🧥 ${firstItem['produk']?['nama_produk'] ?? '-'} x${firstItem['jumlah']}",
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (additionalCount > 0)
                      Text(
                        "+$additionalCount produk lainnya",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "📦 Total: $totalItems produk",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "💸 ${currencyFormatter.format(totalHarga)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetailPage(Map<String, dynamic> order, String status) {
    Widget detailPage;
    switch (status) {
      case 'Belum Bayar':
        detailPage = OrderDetailUnpaidPage(order: order, tabStatus: status);
        break;
      case 'Diproses':
        detailPage = OrderDetailProcessingPage(order: order, tabStatus: status);
        break;
      case 'Dikirim':
        detailPage = OrderDetailShippedPage(order: order, tabStatus: status);
        break;
      case 'Selesai':
      default:
        detailPage = OrderDetailReceivedPage(order: order);
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => detailPage));
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Belum Bayar':
        color = Colors.orange;
        break;
      case 'Diproses':
        color = Colors.blue;
        break;
      case 'Dikirim':
        color = Colors.purple;
        break;
      case 'Selesai':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
