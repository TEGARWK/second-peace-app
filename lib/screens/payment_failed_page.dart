import 'package:flutter/material.dart';

class PaymentFailedPage extends StatelessWidget {
  const PaymentFailedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cancel_outlined, size: 100, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Pembayaran Gagal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Oops! Pembayaran Anda tidak berhasil. Coba lagi atau gunakan metode pembayaran lain.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
