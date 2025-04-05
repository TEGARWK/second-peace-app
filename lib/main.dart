import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secondpeacem/screens/product_wrapper.dart';
import 'package:secondpeacem/screens/orders_page.dart';
import 'package:secondpeacem/screens/account_page.dart';
import 'package:secondpeacem/widgets/custom_navbar.dart';
import 'package:secondpeacem/providers/cart_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const SecondPeaceApp(),
    ),
  );
}

class SecondPeaceApp extends StatelessWidget {
  const SecondPeaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 32, 32, 32),
        fontFamily: 'Arial',
      ),
      initialRoute: '/',
      routes: {'/': (context) => const MainScreen()},
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNavIndex();
  }

  Future<void> _loadNavIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('navIndex') ?? 0;
      prefs.remove('navIndex');
    });
  }

  final List<Widget> _pages = const [
    ProductWrapper(),
    OrdersPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isAccountPage = _selectedIndex == 2;

    return Scaffold(
      extendBodyBehindAppBar: isAccountPage,
      backgroundColor: Colors.white,
      appBar:
          isAccountPage
              ? null
              : PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: CustomNavbar(showSearchBox: _selectedIndex == 0),
              ),
      body: SafeArea(top: !isAccountPage, child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
