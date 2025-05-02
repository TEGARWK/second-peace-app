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

  @override
  void initState() {
    super.initState();
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
              onNavigationRequest: (request) {
                final url = request.url;
                print('[WEBVIEW] Navigating to: $url');

                if (url.contains('finish') || url.contains('status=success')) {
                  _handleSukses();
                  return NavigationDecision.prevent;
                }

                if (url.contains('unfinish') || url.contains('error')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pembayaran dibatalkan atau gagal'),
                    ),
                  );
                  Navigator.pop(context);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(
            Uri.parse(
              "https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}",
            ),
          );
  }

  Future<void> _handleSukses() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil!")));

    await Future.delayed(const Duration(seconds: 2));

    // Redirect ke homepage
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    }
  }

  Future<void> _cekStatusPembayaran() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/verify-payment/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      print('[CEK STATUS] response: $data');

      if (data['status'] == 'settlement') {
        _handleSukses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status Pembayaran: ${data['status']}')),
        );
      }
    } catch (e) {
      print('❌ Gagal cek status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal cek status pembayaran')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: Colors.white,
            child: ElevatedButton(
              onPressed: _cekStatusPembayaran,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Cek Status Pembayaran",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
