import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅
import 'package:secondpeacem/screens/orders_page.dart';
import 'package:secondpeacem/screens/account_page.dart';
import 'package:secondpeacem/widgets/custom_navbar.dart';
import 'package:secondpeacem/providers/cart_provider.dart';
import 'package:secondpeacem/services/cart_service.dart';
import 'package:secondpeacem/screens/snap_webview_page.dart';
import 'package:secondpeacem/screens/product_wrapper.dart';
import 'package:secondpeacem/screens/register_page.dart';
import 'package:secondpeacem/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // ✅

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final cartService = CartService(
    baseUrl: 'http://10.0.2.2:8000/api',
    token: token,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(cartService: cartService),
        ),
      ],
      child: SecondPeaceApp(isLoggedIn: token.isNotEmpty),
    ),
  );
}

class SecondPeaceApp extends StatelessWidget {
  final bool isLoggedIn;
  const SecondPeaceApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 32, 32, 32),
        fontFamily: 'Arial',
      ),
      localizationsDelegates: const [
        // ✅
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        // ✅
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      initialRoute: isLoggedIn ? '/main' : '/register',
      routes: {
        '/': (context) => const MainScreen(),
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/snap': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return SnapWebViewPage(
            snapToken: args['snap_token'],
            orderId: args['order_id'],
          );
        },
        '/success': (context) => const PembayaranSuksesPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadNavIndex();
    _pages = [ProductWrapper(), const OrdersPage(), const AccountPage()];
  }

  Future<void> _loadNavIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('navIndex') ?? 0;
      prefs.remove('navIndex');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAccountPage = _selectedIndex == 2;

    return Scaffold(
      extendBodyBehindAppBar: isAccountPage,
      backgroundColor: Colors.white,
      appBar:
          isAccountPage
              ? null
              : const PreferredSize(
                preferredSize: Size.fromHeight(80),
                child: CustomNavbar(),
              ),
      body: SafeArea(top: !isAccountPage, child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}

class PembayaranSuksesPage extends StatelessWidget {
  const PembayaranSuksesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembayaran Berhasil"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "Terima kasih! Pesanan kamu sedang diproses.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
