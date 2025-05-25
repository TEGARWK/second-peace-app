import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_navbar.dart';
import '../services/auth_service.dart';
import '../services/shipping_service.dart';
import 'alamat_list.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;

  const CheckoutPage({Key? key, required this.selectedItems}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Map<String, dynamic>? selectedAddress;
  bool isProcessing = false;
  bool isLoadingCourier = false;
  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List<Map<String, dynamic>> courierOptions = [];
  Map<String, dynamic>? selectedCourierOption;
  String? selectedCourierCode;

  @override
  void initState() {
    super.initState();
    _loadPrimaryAddress();
  }

  Future<void> _loadPrimaryAddress({Map<String, dynamic>? override}) async {
    if (override != null) {
      setState(() {
        selectedAddress = override;
        selectedCourierOption = null;
        courierOptions = [];
      });
      _loadCourierOptions();
      return;
    }

    try {
      final addresses = await AuthService().getAddresses();
      if (addresses.isNotEmpty) {
        final primary = addresses.firstWhere(
          (addr) => addr['utama'] == true || addr['utama'] == 1,
          orElse: () => addresses.first,
        );
        setState(() {
          selectedAddress = primary;
        });
        _loadCourierOptions();
      }
    } catch (e) {
      print('❌ Gagal memuat alamat utama: $e');
    }
  }

  Future<void> _loadCourierOptions() async {
    if (selectedAddress == null) return;

    if (selectedCourierCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih kurir terlebih dahulu")),
      );
      return;
    }

    // ✅ Hitung berat otomatis
    int totalWeight = widget.selectedItems.fold<int>(0, (sum, item) {
      final qty = int.tryParse(item['quantity'].toString()) ?? 1;
      return sum + (qty * 300);
    });

    setState(() => isLoadingCourier = true);
    try {
      final costResults = await ShippingService().getCosts(
        originCityId: "501", // Kab. Indramayu
        destinationCityId: selectedAddress!['kota_id'].toString(),
        weight: totalWeight,
        courier: selectedCourierCode!,
      );

      setState(() {
        courierOptions = costResults;
        selectedCourierOption = null;
      });
    } catch (e) {
      print("❌ Gagal memuat ongkir: $e");
    } finally {
      setState(() => isLoadingCourier = false);
    }
  }

  Future<void> _bayarSekarang(double totalHarga) async {
    if (selectedCourierOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih layanan pengiriman terlebih dahulu"),
        ),
      );
      return;
    }

    try {
      final produkList =
          widget.selectedItems
              .map(
                (item) => {
                  'id_produk': item['id_produk'],
                  'jumlah': item['quantity'] ?? 1,
                },
              )
              .toList();

      final response = await AuthService().checkout(
        produkList,
        ekspedisi: selectedCourierOption!['service'],
        ongkir: selectedCourierOption!['cost'],
        estimasi: selectedCourierOption!['etd'],
      );

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
        throw Exception('Snap token/order_id tidak tersedia');
      }
    } catch (e) {
      print("❌ Error saat checkout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memproses pembayaran")),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAddressBox() {
    final name = selectedAddress?['nama'] ?? '-';
    final phone = selectedAddress?['no_whatsapp'] ?? '-';
    final address = selectedAddress?['alamat'] ?? '-';
    final city = selectedAddress?['kota_nama'] ?? '-';
    final province = selectedAddress?['provinsi_nama'] ?? '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(phone),
            const SizedBox(height: 8),
            Text(address),
            Text('$city, $province'),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DaftarAlamatPage()),
                  );
                  await _loadPrimaryAddress(override: result);
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Ubah Alamat"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSummary() {
    return Column(
      children:
          widget.selectedItems.map((item) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item['image'] ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
              title: Text(item['name'] ?? '-'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Qty: ${item['quantity']}"),
                  Text("Harga: ${formatCurrency.format(item['price'])}"),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCourierSelector() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Pilih Kurir'),
      value: selectedCourierCode,
      items: const [
        DropdownMenuItem(value: 'jne', child: Text('JNE')),
        DropdownMenuItem(value: 'tiki', child: Text('TIKI')),
        DropdownMenuItem(value: 'pos', child: Text('POS Indonesia')),
      ],
      onChanged: (value) {
        setState(() {
          selectedCourierCode = value;
          selectedCourierOption = null;
          courierOptions = [];
        });
        _loadCourierOptions();
      },
    );
  }

  Widget _buildCourierCard() {
    if (isLoadingCourier) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return courierOptions.isEmpty
        ? const Text("Tidak ada layanan tersedia")
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              courierOptions.map((option) {
                final label = "${option['service']} - ${option['etd']} hari";
                final cost = option['cost'];
                final isSelected = selectedCourierOption == option;

                return ListTile(
                  leading: const Icon(Icons.local_shipping),
                  title: Text(label),
                  subtitle: Text(
                    formatCurrency.format((cost as num).toDouble()),
                  ),

                  trailing:
                      isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                  onTap: () {
                    setState(() {
                      selectedCourierOption = option;
                    });
                  },
                );
              }).toList(),
        );
  }

  Widget _buildFooter(double subtotal, double ongkir, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text(formatCurrency.format(subtotal)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ongkir'),
              Text(formatCurrency.format(ongkir)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                formatCurrency.format(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed:
                isProcessing
                    ? null
                    : () async {
                      setState(() => isProcessing = true);
                      final subtotal = widget.selectedItems.fold<double>(
                        0.0,
                        (sum, item) =>
                            sum +
                            ((item['price'] as num) * (item['quantity'] ?? 1)),
                      );
                      await _bayarSekarang(subtotal);
                      setState(() => isProcessing = false);
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.selectedItems.fold<double>(
      0.0,
      (sum, item) => sum + ((item['price'] as num) * (item['quantity'] ?? 1)),
    );
    final ongkir = (selectedCourierOption?['cost'] ?? 0).toDouble();

    final total = subtotal + ongkir;

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
            _buildSectionTitle("Alamat Pengiriman"),
            _buildAddressBox(),
            _buildSectionTitle("Produk Dibeli"),
            _buildProductSummary(),
            _buildSectionTitle("Kurir Pengiriman"),
            _buildCourierSelector(),
            const SizedBox(height: 12),
            _buildCourierCard(),
            _buildSectionTitle("Ringkasan"),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Subtotal: ${formatCurrency.format(subtotal)}"),
                  Text("Ongkir: ${formatCurrency.format(ongkir)}"),
                  const Divider(),
                  Text(
                    "Total: ${formatCurrency.format(total)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(subtotal, ongkir, total),
    );
  }
}
