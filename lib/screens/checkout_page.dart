import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_navbar.dart';
import '../services/auth_service.dart';
import 'alamat_list.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;

  const CheckoutPage({Key? key, required this.selectedItems}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedCourier;
  String userName = "";
  String userAddress = "";
  String userPhone = "";
  bool isProcessing = false;

  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final Map<String, int> courierEstimates = {'J&T': 2, 'JNE': 3, 'SiCepat': 1};

  @override
  void initState() {
    super.initState();
    _loadPrimaryAddress(); // Memuat alamat pertama
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPrimaryAddress(); // Memuat ulang jika ada perubahan alamat utama
  }

  Future<void> _loadPrimaryAddress() async {
    try {
      final addresses = await AuthService().getAddresses();
      if (addresses.isNotEmpty) {
        final primary = addresses.firstWhere(
          (addr) => addr['utama'] == true,
          orElse: () => addresses.first,
        );

        setState(() {
          userName = primary['nama'] ?? '';
          userPhone = primary['no_whatsapp'] ?? '';
          userAddress = "${primary['alamat'] ?? ''}";
        });
      }
    } catch (e) {
      print('❌ Gagal memuat alamat utama: $e');
    }
  }

  Future<void> _bayarSekarang(double totalHarga) async {
    if (selectedCourier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih kurir terlebih dahulu")),
      );
      return;
    }

    try {
      final authService = AuthService();

      Map<String, dynamic> response;

      if (widget.selectedItems.isEmpty) {
        response = await authService.checkoutFromCart();
      } else {
        final List<Map<String, dynamic>> produkList =
            widget.selectedItems.map((item) {
              return {
                'id_produk': item['id_produk'],
                'jumlah': item['quantity'] ?? 1,
              };
            }).toList();

        response = await authService.checkout(
          produkList,
          paymentMethod:
              'gopay', // pastikan ini benar dan tersedia di Midtrans kamu
          ekspedisi: selectedCourier!,
        );
      }

      print("🧾 Response Checkout: $response");

      if (response.containsKey('snap_token') &&
          response.containsKey('order_id')) {
        Navigator.pushNamed(
          context,
          '/snap',
          arguments: {
            'snap_token': response['snap_token'],
            'order_id': response['order_id'],
          },
        );
      } else {
        throw Exception('Snap token/order_id tidak tersedia di response');
      }
    } catch (e) {
      print("❌ Gagal saat checkout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memproses pembayaran")),
      );
    }
  }

  List<String> _generateDateRange(int days) {
    final now = DateTime.now();
    final start = now.add(Duration(days: days));
    final end = now.add(Duration(days: days + 3));
    final dateFormat = DateFormat('d');
    final monthFormat = DateFormat('MMM');
    return [
      "${dateFormat.format(start)} - ${dateFormat.format(end)} ${monthFormat.format(end)}",
    ];
  }

  void _showCourierOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => ListView(
            shrinkWrap: true,
            children:
                courierEstimates.entries.map((entry) {
                  return ListTile(
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: Text(entry.key),
                    subtitle: Text(
                      "Estimasi: ${_generateDateRange(entry.value).first}",
                    ),
                    onTap: () {
                      setState(() {
                        selectedCourier = entry.key;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.selectedItems.fold(
      0,
      (sum, item) => sum + ((item['price'] as num) * (item['quantity'] ?? 1)),
    );

    return Scaffold(
      appBar: const CustomNavbar(
        isDetailPage: true,
        showCart: false,
        title: "Checkout",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Alamat Pengiriman'),
            _buildAddressBox(),
            const SizedBox(height: 20),
            _buildSectionTitle('Ringkasan Produk'),
            _buildProductSummary(),
            const SizedBox(height: 20),
            _buildSectionTitle('Pengiriman'),
            _buildCourierCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(totalPrice),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAddressBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.black54),
                onPressed: () async {
                  final selected = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DaftarAlamatPage()),
                  );

                  if (selected != null) {
                    setState(() {
                      userName = selected['nama'] ?? '';
                      userPhone = selected['no_whatsapp'] ?? '';
                      userAddress = "${selected['alamat'] ?? ''}";
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nama penerima
          Row(
            children: [
              const Icon(Icons.person_outline, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Nomor WA
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              Text(userPhone, style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),

          // Alamat lengkap
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(userAddress, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductSummary() {
    return Column(
      children: List.generate(widget.selectedItems.length, (index) {
        final item = widget.selectedItems[index];

        return Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['image'] ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => const Icon(Icons.broken_image),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency.format(item['price']),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Qty: ${item['quantity'] ?? 1}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (index != widget.selectedItems.length - 1)
              const Divider(thickness: 1, height: 20),
          ],
        );
      }),
    );
  }

  Widget _buildCourierCard() {
    final estDate =
        selectedCourier != null
            ? _generateDateRange(courierEstimates[selectedCourier!]!).first
            : '-';

    return GestureDetector(
      onTap: _showCourierOptions,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900, // Warna dasar modern (dark grey)
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Estimasi tiba: $estDate",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedCourier != null
                        ? "Pengiriman ${selectedCourier!}"
                        : "Pilih Pengiriman",
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                  ),
                ],
              ),
            ),
            Row(
              children: const [
                Icon(Icons.local_shipping_outlined, color: Color(0xFF00FFB0)),
                SizedBox(width: 6),
                Text(
                  "Gratis",
                  style: TextStyle(
                    color: Color(0xFF00FFB0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total: ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                formatCurrency.format(totalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  isProcessing
                      ? null
                      : () async {
                        setState(() => isProcessing = true);
                        double totalPrice = widget.selectedItems.fold<double>(
                          0.0,
                          (sum, item) =>
                              sum +
                              ((item['price'] as num) *
                                  (item['quantity'] ?? 1)),
                        );
                        await _bayarSekarang(totalPrice);
                        setState(() => isProcessing = false);
                      },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
