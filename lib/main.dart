import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboards/owner_dashboard.dart';
import 'screens/dashboards/superadmin_dashboard.dart';
import 'screens/dashboards/admin_dashboard.dart';
import 'screens/dashboards/manager_dashboard.dart';
import 'screens/dashboards/employee_pos_screen.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const ShopJSApp(),
    ),
  );
}

class ShopJSApp extends StatefulWidget {
  const ShopJSApp({Key? key}) : super(key: key);

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
          builder: (context, state) => const EmployeePOSScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShopJS',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50], // Light grey background
        fontFamily: 'Inter',
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
