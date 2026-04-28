import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboards/owner_dashboard.dart';
import 'screens/dashboards/superadmin_dashboard.dart';
import 'screens/dashboards/admin_dashboard.dart';
import 'screens/dashboards/manager_dashboard.dart';
import 'screens/dashboards/employee_dashboard.dart';
import 'screens/pos/barcode_scanner_screen.dart';
import 'screens/pos/pos_cart_screen.dart';
import 'screens/pos/invoice_preview_screen.dart';
import 'screens/pos/pos_main_screen.dart';
import 'screens/pos/pos_scanner_modal.dart';
import 'screens/history/customer_list_screen.dart';
import 'screens/shop/coupon_management_screen.dart';
import 'screens/shop/shop_settings_screen.dart';
import 'screens/history/transaction_history_screen.dart';
import 'screens/analytics/sales_analytics_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const ShopJSApp(),
    ),
  );
}

class ShopJSApp extends StatefulWidget {
  const ShopJSApp({super.key});

  @override
  State<ShopJSApp> createState() => _ShopJSAppState();
}

class _ShopJSAppState extends State<ShopJSApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();

    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool loggedIn = authProvider.isAuthenticated;
        final bool isLoginPath = state.matchedLocation == '/login';

        if (!loggedIn && !isLoginPath) {
          return '/login';
        }

        if (loggedIn && isLoginPath) {
          final role = authProvider.role ?? '';
          return '/$role';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/owner',
          builder: (context, state) => const OwnerDashboard(),
        ),
        // Add other roles here
        GoRoute(
          path: '/superadmin',
          builder: (context, state) => const SuperAdminDashboard(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboard(),
        ),
        GoRoute(
          path: '/manager',
          builder: (context, state) => const ManagerDashboard(),
        ),
        GoRoute(
          path: '/employee',
          builder: (context, state) => const EmployeeDashboard(),
        ),
        GoRoute(
          path: '/pos-scanner',
          builder: (context, state) => const BarcodeScannerScreen(),
        ),
        GoRoute(
          path: '/pos-main',
          builder: (context, state) => const POSMainScreen(),
        ),
        GoRoute(
          path: '/pos-scanner-modal',
          builder: (context, state) => const POSScannerModal(),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const POSCartScreen(),
        ),
        GoRoute(
          path: '/invoice',
          builder: (context, state) {
            final orderData = state.extra as Map<String, dynamic>? ?? {};
            return InvoicePreviewScreen(orderData: orderData);
          },
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const TransactionHistoryScreen(),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomerListScreen(),
        ),
        GoRoute(
          path: '/coupons',
          builder: (context, state) => const CouponManagementScreen(),
        ),
        GoRoute(
          path: '/shop-settings',
          builder: (context, state) => const ShopSettingsScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const SalesAnalyticsScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShopJS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Deep vibrant green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
