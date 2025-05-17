import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SnapWebViewPage extends StatefulWidget {
  final String snapToken;
  final String orderId;

  const SnapWebViewPage({
    Key? key,
    required this.snapToken,
    required this.orderId,
  }) : super(key: key);

  @override
  State<SnapWebViewPage> createState() => _SnapWebViewPageState();
}

class _SnapWebViewPageState extends State<SnapWebViewPage> {
  late final WebViewController _controller;
  bool isLoading = true;
  bool paymentSuccess = false;
  final bool useProduction = false;
  bool tokenValid = true;
  String statusMessage = "Mengecek status pembayaran...";

  @override
  void initState() {
    super.initState();
    _initWebView();
    Future.delayed(const Duration(seconds: 5), _startAutoCheck);
  }

  void _initWebView() {
    final baseSnapUrl =
        useProduction
            ? 'https://app.midtrans.com/snap/v2/vtweb/'
            : 'https://app.sandbox.midtrans.com/snap/v2/vtweb/';

    if (widget.snapToken.isEmpty || widget.snapToken.length < 20) {
      setState(() => tokenValid = false);
      return;
    }

    final fullUrl = '$baseSnapUrl${widget.snapToken}';
    print('🔗 Opening Snap URL: $fullUrl');

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) => setState(() => isLoading = true),
              onPageFinished: (_) => setState(() => isLoading = false),
              onWebResourceError: (error) {
                print("❌ Web error: ${error.description}");
              },
            ),
          )
          ..loadRequest(Uri.parse(fullUrl));
  }

  void _startAutoCheck() async {
    if (!mounted || paymentSuccess) return;
    await _cekStatusPembayaran();

    if (!paymentSuccess && mounted) {
      Future.delayed(const Duration(seconds: 5), _startAutoCheck);
    }
  }

  Future<void> _handleSukses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('navIndex', 1);

    setState(() {
      paymentSuccess = true;
      statusMessage = "Pembayaran berhasil! Mengarahkan...";
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil!")));

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    }
  }

  Future<void> _cekStatusPembayaran() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(
          'https://secondpeace.my.id/api/v1/verify-payment/${widget.orderId}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('[CEK STATUS] response: $data');

        if (data['status'] == 'settlement') {
          await _handleSukses();
        } else {
          setState(() {
            statusMessage = 'Status saat ini: ${data['status']}';
          });
        }
      } else {
        print('❌ Gagal verifikasi status pembayaran: ${response.statusCode}');
        setState(() {
          statusMessage = 'Gagal verifikasi status pembayaran';
        });
      }
    } catch (e) {
      print('❌ Error cek status: $e');
      setState(() {
        statusMessage = 'Gagal cek status pembayaran';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!tokenValid) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Pembayaran"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Snap token tidak valid. Silakan kembali dan ulangi proses checkout.",
              style: TextStyle(fontSize: 16, color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          if (!paymentSuccess)
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(
                    statusMessage,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
