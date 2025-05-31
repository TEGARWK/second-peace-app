import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Pages & Widgets
import 'package:secondpeacem/screens/orders_page.dart';
import 'package:secondpeacem/screens/account_page.dart';
import 'package:secondpeacem/widgets/custom_navbar.dart';
import 'package:secondpeacem/providers/cart_provider.dart';
import 'package:secondpeacem/services/cart_service.dart';
import 'package:secondpeacem/screens/snap_webview_page.dart';
import 'package:secondpeacem/screens/product_wrapper.dart';
import 'package:secondpeacem/screens/register_page.dart';
import 'package:secondpeacem/screens/login_page.dart';
import 'package:secondpeacem/providers/notification_provider.dart';
import 'package:secondpeacem/screens/order_detail_processing_page.dart';
import 'package:secondpeacem/screens/order_detail_shipped_page.dart';
import 'package:secondpeacem/screens/order_detail_received_page.dart';
import 'package:secondpeacem/screens/order_detail_cancelled_page.dart';
import 'package:secondpeacem/screens/order_detail_unpaid_page.dart';
import 'package:secondpeacem/screens/chat_page.dart';

// ✅ Tambahkan RouteObserver global
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final prefs = snapshot.data!;
        final token = prefs.getString('token') ?? '';
        final isLoggedIn = token.isNotEmpty;

        final cartService = CartService(
          //baseUrl: 'https://secondpeace.my.id/api/v1',
          baseUrl: 'http://10.0.2.2:8000/api/v1',
          token: token,
        );

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => CartProvider(cartService: cartService),
            ),
            ChangeNotifierProvider(
              create: (_) => NotificationProvider()..fetchUnreadCount(),
            ),
          ],
          child: SecondPeaceApp(isLoggedIn: isLoggedIn),
        );
      },
    );
  }
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
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      navigatorObservers: [routeObserver], // ✅ tambahkan ini
      initialRoute: isLoggedIn ? '/' : '/login', // ✅ agar login dulu

      routes: {
        '/': (context) => const MainScreen(),
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/snap': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return SnapWebViewPage(
              snapToken: args['snap_token'],
              orderId: args['order_id'],
            );
          }
          return const Scaffold(
            body: Center(child: Text("Invalid snap token data")),
          );
        },
        '/success': (context) => const PembayaranSuksesPage(),
        '/order-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          if (args is Map<dynamic, dynamic>) {
            final order = Map<String, dynamic>.from(args);
            final status = order['status'] ?? order['status_pesanan'] ?? '';

            if (status == 'Pesanan Dikirim') {
              return OrderDetailShippedPage(idPesanan: order['id_pesanan']);
            } else if (status == 'Pesanan Diterima') {
              return OrderDetailReceivedPage(order: order);
            } else if (status == 'Pesanan Dibatalkan') {
              return OrderDetailCancelledPage(order: order); // kalau ada
            } else if (status == 'Menunggu Pembayaran') {
              return OrderDetailUnpaidPage(
                order: order,
                tabStatus: status, // ✅ tambahkan ini
              );
            } else {
              return OrderDetailProcessingPage(order: order, tabStatus: status);
            }
          }

          return const Scaffold(
            body: Center(child: Text("Data notifikasi tidak valid")),
          );
        },
        '/chat': (context) => const ChatPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [ProductWrapper(), const OrdersPage(), const AccountPage()];
    _loadNavIndex();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Panggil sekali saat build awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchUnreadCount();
    });

    // Subscribe route observer
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Saat kembali ke halaman utama
    print('🔁 didPopNext: refresh notif count');
    context.read<NotificationProvider>().fetchUnreadCount();
  }

  @override
  void didPushNext() {
    // Saat pergi ke halaman lain dari MainScreen
    print('📤 didPushNext: refresh notif count');
    context.read<NotificationProvider>().fetchUnreadCount();
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

    // Tambahan keamanan: refresh notif setiap ganti tab
    context.read<NotificationProvider>().fetchUnreadCount();
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
