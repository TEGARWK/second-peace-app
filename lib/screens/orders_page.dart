import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../data/dummy_accounts.dart';
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
    final userId = prefs.getInt('userId');

    if (userId != null) {
      final user = dummyAccounts.firstWhere(
        (acc) => acc['id'] == userId,
        orElse: () => {},
      );

      if (user.isEmpty) return;

      final allOrders = List<Map<String, dynamic>>.from(user['orders'] ?? []);

      setState(() {
        unpaid = allOrders.where((o) => o['status'] == 'Belum Bayar').toList();
        processing = allOrders.where((o) => o['status'] == 'Diproses').toList();
        shipped = allOrders.where((o) => o['status'] == 'Dikirim').toList();
        received = allOrders.where((o) => o['status'] == 'Selesai').toList();
      });
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
          final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
          final firstItem = items.isNotEmpty ? items[0] : null;
          final totalItems = items.fold(
            0,
            (sum, item) => sum + (item['quantity'] ?? 0) as int,
          );

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
                    // Header Row: Order ID & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "No. ${order['orderId']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tanggal: ${order['date']}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const Divider(height: 24),
                    // First product preview
                    if (firstItem != null)
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 28,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              items.length > 1
                                  ? "${firstItem['name']} x${firstItem['quantity']} dan ${items.length - 1} produk lainnya"
                                  : "${firstItem['name']} x${firstItem['quantity']}",
                              style: const TextStyle(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    // Footer Row: Total items & Total Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$totalItems produk",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          currencyFormatter.format(order['total']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
