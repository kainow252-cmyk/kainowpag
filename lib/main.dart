import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_provider.dart';

// Importação condicional para web
import 'dart:html' as html show window;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => APIProvider(),
      child: const PaymentMasterApp(),
    ),
  );
}

class PaymentMasterApp extends StatefulWidget {
  const PaymentMasterApp({super.key});

  @override
  State<PaymentMasterApp> createState() => _PaymentMasterAppState();
}

class _PaymentMasterAppState extends State<PaymentMasterApp> {
  Widget? _initialScreen;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndDeepLink();
  }

  Future<void> _checkAuthAndDeepLink() async {
    // Detectar deep link ANTES de verificar autenticação
    String? checkoutProductId;
    
    if (kIsWeb) {
      try {
        final path = html.window.location.pathname ?? '/';
        final hash = html.window.location.hash ?? '';
        
        if (kDebugMode) {
          debugPrint('🔗 Deep link - Path: $path, Hash: $hash');
        }
        
        // Verificar se é rota de checkout
        // Opção 1: Rota /checkout/:id
        if (path.startsWith('/checkout/')) {
          checkoutProductId = path.replaceFirst('/checkout/', '').split('?').first;
        }
        // Opção 2: Hash #/checkout/:id (para compatibilidade)
        else if (hash.startsWith('#/checkout/')) {
          checkoutProductId = hash.replaceFirst('#/checkout/', '').split('?').first;
        }
        
        if (checkoutProductId != null && checkoutProductId.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('📦 Opening checkout for product: $checkoutProductId (customer mode)');
          }
          // Deep link de checkout = NÃO requer login (modo cliente)
          setState(() {
            _initialScreen = CheckoutScreen(
              productId: checkoutProductId!,
              showAdminTools: false, // Cliente não vê link nem API
            );
            _isCheckingAuth = false;
          });
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ Error detecting deep link: $e');
        }
      }
    }
    
    // Se não é checkout, verificar autenticação
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    if (kDebugMode) {
      debugPrint('🔐 Login status: $isLoggedIn');
    }
    
    setState(() {
      _initialScreen = isLoggedIn ? const HomeScreen() : const LoginScreen();
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kainowpag',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      home: _isCheckingAuth
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : (_initialScreen ?? const LoginScreen()),
    );
  }
}


