import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'edit_profile_page.dart';
import 'alamat_list.dart';
import 'riwayat_pesanan_page.dart';
import 'cart_page.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isLoggedIn = false;
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? email = prefs.getString('userEmail');
    String? name = prefs.getString('userName'); // Ambil nama dari prefs juga

    if (loggedIn && email != null) {
      setState(() {
        isLoggedIn = true;
        userName = name ?? "User"; // fallback ke 'User' kalau null
        userEmail = email;
      });
    } else {
      setState(() {
        isLoggedIn = false;
        userName = null;
        userEmail = null;
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      isLoggedIn = false;
      userName = null;
      userEmail = null;
    });

    // Redirect ke homepage (index 0)
    await prefs.setInt('navIndex', 0);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (isLoggedIn) ...[
                  _buildPesananSaya(),
                  _buildMenuSection(),
                ] else
                  _buildLoggedOutView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      expandedHeight: 160,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(color: const Color.fromARGB(255, 0, 0, 0)),
            Positioned(
              left: 16,
              top: MediaQuery.of(context).padding.top + 12,
              child: const Text(
                "Welcome",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn ? userName ?? "-" : "Tamu",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isLoggedIn)
                        Text(
                          userEmail ?? "-",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat, color: Colors.white),
          onPressed: () {},
        ),
        Consumer<CartProvider>(
          builder: (context, cart, child) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                ),
                if (cart.totalItems > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                      child: Container(
                        key: ValueKey(cart.totalItems),
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${cart.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPesananSaya() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: const Text("Pesanan Saya"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RiwayatPesananPage()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _orderIcon(Icons.payment, "Belum Bayar"),
                _orderIcon(Icons.local_shipping, "Dikirim"),
                _orderIcon(Icons.inbox, "Dikemas"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(Icons.person, "Edit Profil", const EditProfilePage()),
        _buildMenuItem(
          Icons.location_on,
          "Alamat Pengiriman",
          const DaftarAlamatPage(),
        ),
        _buildMenuItem(Icons.logout, "Keluar", null, isLogout: true),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Widget? page, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: isLogout ? const Text("Keluar dari akun") : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        if (isLogout) {
          await _logout();
        } else if (page != null) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
          // Refresh data setelah balik dari halaman lain
          _checkLoginStatus();
        }
      },
    );
  }

  Widget _buildLoggedOutView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ).then((_) => _checkLoginStatus());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text(
              "Login",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ).then((_) => _checkLoginStatus());
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Colors.black),
            ),
            icon: const Icon(Icons.app_registration, color: Colors.black),
            label: const Text(
              "Register",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
