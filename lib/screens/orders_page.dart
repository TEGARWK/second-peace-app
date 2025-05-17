import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'order_detail_unpaid_page.dart';
import 'order_detail_processing_page.dart';
import 'order_detail_shipped_page.dart' as pageShipped;
import 'order_detail_received_page.dart' as pageReceived;
import 'order_detail_cancelled_page.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with TickerProviderStateMixin, RouteAware {
  List<Map<String, dynamic>> unpaid = [];
  List<Map<String, dynamic>> processing = [];
  List<Map<String, dynamic>> shipped = [];
  List<Map<String, dynamic>> received = [];
  List<Map<String, dynamic>> cancelled = [];

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
    _pollForUpdatedOrders(); // Mulai polling setelah inisialisasi
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadUserOrders(); // Reload setelah kembali ke halaman
  }

  String mapStatusToTab(String backendStatus) {
    print('🔥 status dari backend: $backendStatus');
    switch (backendStatus) {
      case 'Menunggu Pembayaran':
        return 'Belum Bayar';
      case 'Pembayaran Diterima':
      case 'Sedang Diproses':
        return 'Diproses';
      case 'Pesanan Dikirim':
        return 'Dikirim';
      case 'Pesanan Diterima':
        return 'Selesai';
      case 'Pesanan Dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Lainnya';
    }
  }

  Future<void> _loadUserOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print('🔑 TOKEN SAAT REQUEST: $token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://secondpeace.my.id/api/v1/pesanan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List orders = data['pesanan'];

        print('📦 total pesanan diterima: ${orders.length}');

        // Periksa jika widget masih terpasang sebelum melakukan update state
        if (mounted) {
          setState(() {
            unpaid = _filterOrders(orders, 'Belum Bayar');
            processing = _filterOrders(orders, 'Diproses');
            shipped = _filterOrders(orders, 'Dikirim');
            received = _filterOrders(orders, 'Selesai');
            cancelled = _filterOrders(orders, 'Dibatalkan');
          });
        }
      } else {
        print('Gagal memuat pesanan: ${response.body}');
      }
    } catch (e) {
      print('❌ Error memuat pesanan: $e');
    }
  }

  List<Map<String, dynamic>> _filterOrders(List orders, String statusTab) {
    return orders
        .where((o) {
          final mapped = mapStatusToTab(o['status_pesanan']);
          print('📍 status_pesanan: ${o['status_pesanan']} ➜ tab: $mapped');
          return mapped == statusTab;
        })
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // Polling untuk memeriksa status pesanan secara periodik
  Future<void> _pollForUpdatedOrders() async {
    while (true) {
      // Pastikan widget masih terpasang sebelum memanggil _loadUserOrders
      if (!mounted) return;

      await _loadUserOrders();
      await Future.delayed(Duration(seconds: 10)); // Polling setiap 10 detik
    }
  }

  Future<void> _updateOrderStatus(
    String orderId,
    String newStatus,
    String resi,
  ) async {
    final response = await http.put(
      Uri.parse('https://secondpeace.my.id/api/v1/pesanan/$orderId'),
      headers: {
        'Authorization': 'Bearer YOUR_TOKEN_HERE',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': newStatus, 'resi': resi}),
    );

    if (response.statusCode == 200) {
      // Update status di local list setelah status diperbarui
      if (mounted) {
        setState(() {
          // Ganti 'processing' dengan daftar yang sesuai (misalnya 'unpaid', 'shipped', etc.)
          final updatedOrder = processing.firstWhere(
            (order) => order['id_pesanan'] == orderId,
          );
          updatedOrder['status_pesanan'] = newStatus;
          updatedOrder['nomor_resi'] = resi;
        });
      }

      // Refresh data setelah perubahan
      _loadUserOrders();
    } else {
      throw Exception('Failed to update order status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          title: const Text(
            'Pesanan Saya',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: TabBar(
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
                Tab(
                  icon: Icon(Icons.cancel_outlined),
                  child: Text('Dibatalkan', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(unpaid, 'Belum Bayar'),
            _buildOrderList(processing, 'Diproses'),
            _buildOrderList(shipped, 'Dikirim'),
            _buildOrderList(received, 'Selesai'),
            _buildOrderList(cancelled, 'Dibatalkan'),
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
          final items = List<Map<String, dynamic>>.from(
            order['detail_pesanan'] ?? [],
          );
          final firstItem = items.isNotEmpty ? items[0] : null;
          final produk = firstItem?['produk'];
          final namaProduk =
              produk != null
                  ? produk['nama_produk'] ?? 'Produk tidak ditemukan'
                  : 'Produk tidak ditemukan';

          final additionalCount = (items.length - 1).clamp(0, items.length);
          final totalItems = items.fold<int>(0, (sum, item) {
            final qty = item['jumlah'];
            return sum + (qty is int ? qty : int.tryParse(qty.toString()) ?? 0);
          });

          final totalHarga = order['grand_total'] ?? 0;
          final formattedDate = order['tanggal'] ?? '-';

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
                          "🧾 ID Pesanan: #${order['id_pesanan'] ?? '-'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        _buildStatusBadge(order['status_pesanan']),
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
                        "🧥 $namaProduk x${firstItem['jumlah'] ?? 0}",
                        style: const TextStyle(fontSize: 14),
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
                    if ((order['nomor_resi'] ?? '').toString().isNotEmpty)
                      Text(
                        "🔢 Resi: ${order['nomor_resi']}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
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
                            fontSize: 15,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
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
        detailPage = pageShipped.OrderDetailShippedPage(order: order);
        break;
      case 'Selesai':
        detailPage = pageReceived.OrderDetailReceivedPage(order: order);
        break;
      case 'Dibatalkan':
        detailPage = OrderDetailCancelledPage(order: order);
        break;
      default:
        detailPage = OrderDetailProcessingPage(order: order, tabStatus: status);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => detailPage));
  }

  Widget _buildStatusBadge(String backendStatus) {
    String displayStatus = mapStatusToTab(backendStatus);
    Color color;

    switch (displayStatus) {
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
      case 'Dibatalkan':
        color = Colors.red;
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
        displayStatus,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
