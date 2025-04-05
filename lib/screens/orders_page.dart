import 'package:flutter/material.dart';
import 'order_detail_unpaid_page.dart';
import 'order_detail_processing_page.dart';
import 'order_detail_shipped_page.dart';
import 'order_detail_received_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> orders = [
    {
      "id": "001",
      "date": "10 Sep 2024",
      "status": "Belum Dibayar",
      "price": "Rp 250.000",
    },
    {
      "id": "002",
      "date": "11 Sep 2024",
      "status": "Diproses",
      "price": "Rp 180.000",
    },
    {
      "id": "003",
      "date": "12 Sep 2024",
      "status": "Dikirim",
      "price": "Rp 120.000",
    },
    {
      "id": "004",
      "date": "15 Sep 2024",
      "status": "Diterima",
      "price": "Rp 350.000",
    },
    {
      "id": "005",
      "date": "10 Sep 2024",
      "status": "Belum Dibayar",
      "price": "Rp 250.000",
    },
    {
      "id": "006",
      "date": "11 Sep 2024",
      "status": "Diproses",
      "price": "Rp 180.000",
    },
    {
      "id": "007",
      "date": "12 Sep 2024",
      "status": "Dikirim",
      "price": "Rp 120.000",
    },
    {
      "id": "008",
      "date": "15 Sep 2024",
      "status": "Diterima",
      "price": "Rp 350.000",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.access_time), text: 'Belum Dibayar'),
            Tab(icon: Icon(Icons.timelapse), text: 'Diproses'),
            Tab(icon: Icon(Icons.local_shipping), text: 'Dikirim'),
            Tab(icon: Icon(Icons.check_circle), text: 'Diterima'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList('Belum Dibayar'),
          _buildOrderList('Diproses'),
          _buildOrderList('Dikirim'),
          _buildOrderList('Diterima'),
        ],
      ),
    );
  }

  Widget _buildOrderList(String status) {
    List<Map<String, String>> filteredOrders =
        orders.where((order) => order['status'] == status).toList();

    if (filteredOrders.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada pesanan.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        var order = filteredOrders[index];
        return GestureDetector(
          onTap: () => _navigateToDetail(order),
          child: _buildOrderItem(order),
        );
      },
    );
  }

  void _navigateToDetail(Map<String, String> order) {
    final status = order['status'];
    if (status == 'Belum Dibayar') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => OrderDetailUnpaidPage(order: order, tabStatus: status!),
        ),
      );
    } else if (status == 'Diproses') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  OrderDetailProcessingPage(order: order, tabStatus: status!),
        ),
      );
    } else if (status == 'Dikirim') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => OrderDetailShippedPage(order: order, tabStatus: 'Dikirim'),
        ),
      );
    } else if (status == 'Diterima') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailReceivedPage(order: order),
        ),
      );
    }
  }

  Widget _buildOrderItem(Map<String, String> order) {
    Color badgeColor;
    switch (order['status']) {
      case 'Belum Dibayar':
        badgeColor = Colors.orange;
        break;
      case 'Diproses':
        badgeColor = Colors.purple;
        break;
      case 'Dikirim':
        badgeColor = Colors.blue;
        break;
      case 'Diterima':
        badgeColor = Colors.green;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pesanan #${order['id']}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order['status']!,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Tanggal: ${order['date']}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['price']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
