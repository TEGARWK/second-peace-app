import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? expandedPayment;
  String? selectedSubPayment;
  String? selectedCourier;
  String userName = "";
  String userAddress = "";
  String userPhone = "";

  final formatCurrency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final Map<String, int> courierEstimates = {'J&T': 2, 'JNE': 3, 'SiCepat': 1};

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final addresses = await AuthService().getAddresses();
      if (addresses.isNotEmpty) {
        final primary = addresses.firstWhere(
          (addr) => addr['utama'] == true,
          orElse: () => addresses.first,
        );

        setState(() {
          userName = primary['nama'] ?? '';
          userPhone = primary['telepon'] ?? '';
          userAddress =
              "${primary['alamat'] ?? ''}, ${primary['kota'] ?? ''} ${primary['kodePos'] ?? ''}";
        });
      }
    } catch (e) {
      print('Gagal memuat data alamat: $e');
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

  void _showPaymentOptions() {
    String? modalExpandedParent = expandedPayment;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final paymentOptions = {
              'Transfer Bank': ['BCA', 'Mandiri', 'BNI', 'BRI'],
              'E-Wallet': ['OVO', 'Gopay', 'DANA'],
              'QRIS': [],
            };

            return ListView(
              shrinkWrap: true,
              children:
                  paymentOptions.entries.map((entry) {
                    bool isExpanded = modalExpandedParent == entry.key;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading:
                              entry.key == 'QRIS'
                                  ? const Icon(Icons.qr_code_scanner)
                                  : entry.key == 'Transfer Bank'
                                  ? const Icon(Icons.account_balance)
                                  : const Icon(Icons.account_balance_wallet),
                          title: Text(entry.key),
                          trailing:
                              entry.value.isNotEmpty
                                  ? Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  )
                                  : null,
                          onTap: () {
                            if (entry.value.isEmpty) {
                              setState(() {
                                expandedPayment = 'QRIS';
                                selectedSubPayment = null;
                              });
                              Navigator.pop(context);
                            } else {
                              setModalState(() {
                                modalExpandedParent =
                                    isExpanded ? null : entry.key;
                              });
                            }
                          },
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState:
                              isExpanded
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                          firstChild: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              children:
                                  entry.value.map((sub) {
                                    return RadioListTile(
                                      activeColor: Colors.green,
                                      title: Text(sub),
                                      value: sub,
                                      groupValue: selectedSubPayment,
                                      onChanged: (value) {
                                        setState(() {
                                          expandedPayment = entry.key;
                                          selectedSubPayment = value.toString();
                                        });
                                        Navigator.pop(context);
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                          secondChild: const SizedBox.shrink(),
                        ),
                      ],
                    );
                  }).toList(),
            );
          },
        );
      },
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
            _buildSectionTitle('Metode Pembayaran'),
            _buildPaymentDisplay(),
            const SizedBox(height: 80),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userPhone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 40, 40, 40),
                  ),
                ),
                const SizedBox(height: 4),
                Text(userAddress, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black54),
            onPressed: () async {
              final selected = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DaftarAlamatPage()),
              );

              if (selected != null && mounted) {
                setState(() {
                  userName = selected['nama'] ?? userName;
                  userPhone = selected['telepon'] ?? userPhone;
                  userAddress =
                      "${selected['alamat'] ?? ''}, ${selected['kota'] ?? ''} ${selected['kodePos'] ?? ''}";
                });
              }
            },
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

  Widget _buildPaymentDisplay() {
    String paymentText = "Pilih Metode Pembayaran";
    if (expandedPayment != null) {
      if (selectedSubPayment != null) {
        paymentText = "$expandedPayment - $selectedSubPayment";
      } else {
        paymentText = expandedPayment!;
      }
    }

    return GestureDetector(
      onTap: _showPaymentOptions,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900, // dark theme
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paymentText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Klik untuk pilih metode",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF00FFB0), // match accent color
              size: 28,
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
                'Total:',
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran berhasil!'),
                    backgroundColor: Colors.green,
                  ),
                );
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
